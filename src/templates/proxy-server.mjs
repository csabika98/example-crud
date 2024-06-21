import express from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';
import { spawn, exec } from 'child_process';
import path from 'path';
import process from 'process';
import { fileURLToPath } from 'url';

// Convert the URL path to a directory path for __dirname
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

const projectRoot = path.resolve(__dirname, '..', '..'); // Adjust this according to your directory structure
const buildDir = path.join(projectRoot, 'cmake-build-debug');
const buildCommand = `cmake.exe --build ${buildDir} --target crud-exe -j 14`;

exec(buildCommand, (error, stdout, stderr) => {
    if (error) {
        console.error(`Error building the project: ${error.message}`);
        return;
    }
    if (stderr) {
        console.error(`Build stderr: ${stderr}`);
        return;
    }
    console.log(`Build stdout: ${stdout}`);

    const backendExecutablePath = path.join(buildDir, 'crud-exe.exe');
    const backendProcess = spawn(backendExecutablePath);

    backendProcess.stdout.on('data', (data) => {
        console.log(`Backend: ${data}`);
    });

    backendProcess.stderr.on('data', (data) => {
        console.error(`Backend error: ${data}`);
    });

    backendProcess.on('close', (code) => {
        console.log(`Backend process exited with code ${code}`);
    });

    app.use((req, res, next) => {
        console.log(`Request received: ${req.method} ${req.url}`);
        next();
    });

    app.use('/api-docs', createProxyMiddleware({
        target: 'http://localhost:8080',
        changeOrigin: true,
        pathRewrite: {'^/oas-3.0.0.json': '/api-docs/oas-3.0.0.json'}
    }));

    app.use('/users', createProxyMiddleware({
        target: 'http://localhost:8080/users',
        changeOrigin: true,
        pathRewrite: {'^/users': '/users'}
    }));

    app.use('/api', createProxyMiddleware({
        target: 'http://localhost:8080',
        changeOrigin: true
    }));

    app.use('/', createProxyMiddleware({
        target: 'http://localhost:5173',
        changeOrigin: true
    }));

    const PORT = 8888;
    app.listen(PORT, () => {
        console.log(`Proxy server running on http://localhost:${PORT}`);
    });

    process.on('exit', () => {
        backendProcess.kill();
    });
});










