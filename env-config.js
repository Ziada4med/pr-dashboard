// Environment Configuration for Netlify
// This script runs before the main application and sets up configuration

(function() {
    // Check if we're in Netlify production
    const isNetlify = window.location.hostname.includes('.netlify.app') || 
                      window.location.hostname.includes('.netlify.com') ||
                      (window.location.protocol === 'https:' && !window.location.hostname.includes('localhost'));
    
    // Set global configuration
    window.DASHBOARD_CONFIG = {
        SUPABASE_URL: isNetlify ? 
            (window.location.search.includes('demo') ? 'DEMO_MODE' : 'ENV_SUPABASE_URL') : 
            'https://your-project.supabase.co',
        SUPABASE_ANON_KEY: isNetlify ? 
            (window.location.search.includes('demo') ? 'DEMO_MODE' : 'ENV_SUPABASE_KEY') : 
            'your-anon-key',
        IS_PRODUCTION: isNetlify,
        IS_DEMO: window.location.search.includes('demo')
    };
    
    // Log configuration status
    if (window.DASHBOARD_CONFIG.IS_DEMO) {
        console.log('🎮 Demo mode active');
    } else if (window.DASHBOARD_CONFIG.IS_PRODUCTION) {
        console.log('🚀 Production mode - configure environment variables in Netlify');
    } else {
        console.log('🛠️ Development mode');
    }
})();
