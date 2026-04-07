import { Env, JWTPayload } from './types';

// Simple HMAC-SHA256 JWT implementation for Cloudflare Workers
async function hmacSign(data: string, secret: string): Promise<string> {
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  const signature = await crypto.subtle.sign('HMAC', key, encoder.encode(data));
  return btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
}

function base64UrlEncode(obj: object): string {
  return btoa(JSON.stringify(obj))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
}

export async function createJWT(userId: string, secret: string): Promise<string> {
  const header = base64UrlEncode({ alg: 'HS256', typ: 'JWT' });
  const payload = base64UrlEncode({
    sub: userId,
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 90, // 90 days
  });
  const data = `${header}.${payload}`;
  const signature = await hmacSign(data, secret);
  return `${data}.${signature}`;
}

export async function verifyJWT(token: string, secret: string): Promise<JWTPayload | null> {
  try {
    const parts = token.split('.');
    if (parts.length !== 3) return null;

    const [header, payload, signature] = parts;
    const data = `${header}.${payload}`;
    const expectedSig = await hmacSign(data, secret);

    if (signature !== expectedSig) return null;

    const decoded: JWTPayload = JSON.parse(atob(payload.replace(/-/g, '+').replace(/_/g, '/')));
    if (decoded.exp < Math.floor(Date.now() / 1000)) return null;

    return decoded;
  } catch {
    return null;
  }
}

export async function requireAuth(request: Request, env: Env): Promise<string | null> {
  const authHeader = request.headers.get('Authorization');
  if (!authHeader?.startsWith('Bearer ')) return null;

  const token = authHeader.slice(7);
  const payload = await verifyJWT(token, env.JWT_SECRET);
  return payload?.sub ?? null;
}

// Verify Apple identity token (simplified - production should use full JWKS verification)
export async function verifyAppleToken(identityToken: string, clientId: string): Promise<string | null> {
  try {
    const parts = identityToken.split('.');
    if (parts.length !== 3) return null;

    const payload = JSON.parse(atob(parts[1].replace(/-/g, '+').replace(/_/g, '/')));

    // Validate audience
    if (payload.aud !== clientId) return null;

    // Validate expiry
    if (payload.exp < Math.floor(Date.now() / 1000)) return null;

    // Validate issuer
    if (payload.iss !== 'https://appleid.apple.com') return null;

    return payload.sub; // Apple user ID
  } catch {
    return null;
  }
}
