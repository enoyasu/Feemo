import Foundation

// MARK: - API Configuration
// To connect to the live backend:
// 1. Deploy Cloudflare Worker: cd backend && wrangler deploy
// 2. Set FEEMO_API_URL in your environment or replace the fallback below

enum APIConfig {
    // Replace with your deployed Workers URL after `wrangler deploy`
    nonisolated static func resolveBaseURL() -> String {
        if let url = ProcessInfo.processInfo.environment["FEEMO_API_URL"] {
            return url
        }
        #if DEBUG
        return "http://localhost:8787"
        #else
        return "https://feemo-api.YOUR_SUBDOMAIN.workers.dev"
        #endif
    }

    nonisolated static func resolveIsConfigured() -> Bool {
        #if DEBUG
        // DEBUG builds only use Live API when FEEMO_API_URL is explicitly set
        return ProcessInfo.processInfo.environment["FEEMO_API_URL"] != nil
        #else
        return !resolveBaseURL().contains("YOUR_SUBDOMAIN")
        #endif
    }
}
