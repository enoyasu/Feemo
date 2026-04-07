import { Env } from './types';
import { handleAppleAuth, handleLogout } from './routes/auth';
import {
  handleGetFeed, handleCreatePost, handleGetMyPosts,
  handleDeletePost, handleAddReaction, handleRemoveReaction
} from './routes/posts';
import {
  handleGetGroups, handleCreateGroup,
  handleGetGroupFeed, handleGroupInvite
} from './routes/groups';
import {
  handleGetNotifications, handleMarkRead, handleMarkAllRead
} from './routes/notifications';
import {
  handleGetMoodLog, handleWeeklySummary, handleMonthSummary,
  handleUpdateNickname, handleRegisterDevice, handleDeleteDevice
} from './routes/profile';
import { errorResponse, jsonResponse } from './utils';

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const path = url.pathname;
    const method = request.method;

    // CORS preflight
    if (method === 'OPTIONS') {
      return new Response(null, {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        },
      });
    }

    try {
      // Auth
      if (path === '/auth/apple' && method === 'POST') return handleAppleAuth(request, env);
      if (path === '/auth/logout' && method === 'POST') return handleLogout(request, env);

      // Posts
      if (path === '/posts/feed' && method === 'GET') return handleGetFeed(request, env);
      if (path === '/posts' && method === 'POST') return handleCreatePost(request, env);
      if (path === '/posts/mine' && method === 'GET') return handleGetMyPosts(request, env);

      const postMatch = path.match(/^\/posts\/([^/]+)$/);
      if (postMatch) {
        const postId = postMatch[1];
        if (method === 'DELETE') return handleDeletePost(request, env, postId);
      }

      const reactionMatch = path.match(/^\/posts\/([^/]+)\/reactions$/);
      if (reactionMatch) {
        const postId = reactionMatch[1];
        if (method === 'POST') return handleAddReaction(request, env, postId);
      }

      const removeReactionMatch = path.match(/^\/posts\/([^/]+)\/reactions\/([^/]+)$/);
      if (removeReactionMatch) {
        const [, postId, reactionType] = removeReactionMatch;
        if (method === 'DELETE') return handleRemoveReaction(request, env, postId, reactionType);
      }

      // Groups
      if (path === '/groups' && method === 'GET') return handleGetGroups(request, env);
      if (path === '/groups' && method === 'POST') return handleCreateGroup(request, env);

      const groupFeedMatch = path.match(/^\/groups\/([^/]+)\/feed$/);
      if (groupFeedMatch && method === 'GET') return handleGetGroupFeed(request, env, groupFeedMatch[1]);

      const groupInviteMatch = path.match(/^\/groups\/([^/]+)\/invite$/);
      if (groupInviteMatch && method === 'POST') return handleGroupInvite(request, env, groupInviteMatch[1]);

      // Notifications
      if (path === '/notifications' && method === 'GET') return handleGetNotifications(request, env);
      if (path === '/notifications/read-all' && method === 'PATCH') return handleMarkAllRead(request, env);

      const notifReadMatch = path.match(/^\/notifications\/([^/]+)\/read$/);
      if (notifReadMatch && method === 'PATCH') return handleMarkRead(request, env, notifReadMatch[1]);

      // Profile / Me
      if (path === '/me/mood-log' && method === 'GET') return handleGetMoodLog(request, env);
      if (path === '/me/mood-summary/week' && method === 'GET') return handleWeeklySummary(request, env);
      if (path === '/me/mood-summary/month' && method === 'GET') return handleMonthSummary(request, env);
      if (path === '/me/nickname' && method === 'PATCH') return handleUpdateNickname(request, env);

      // Devices
      if (path === '/devices/register' && method === 'POST') return handleRegisterDevice(request, env);

      const deviceMatch = path.match(/^\/devices\/([^/]+)$/);
      if (deviceMatch && method === 'DELETE') return handleDeleteDevice(request, env, deviceMatch[1]);

      // Health check
      if (path === '/' && method === 'GET') return jsonResponse({ ok: true, service: 'Feemo API' });

      return errorResponse('Not found', 404);
    } catch (err) {
      console.error('Unhandled error:', err);
      return errorResponse('Internal server error', 500);
    }
  },
};
