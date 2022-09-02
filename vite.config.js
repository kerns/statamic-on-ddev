import laravel from "laravel-vite-plugin";
import { defineConfig, loadEnv } from "vite";

export default defineConfig(({ command, mode }) => {
    const env = loadEnv(mode, process.cwd(), "");
    return {
        plugins: [laravel(["resources/css/site.css", "resources/js/site.js"])],
        server: {
            host: "0.0.0.0",
            strictPort: false,
            open: false,
            hmr: {
                protocol: "wss",
                host: env.VITE_APP_URL,
            },
        },
    };
});
