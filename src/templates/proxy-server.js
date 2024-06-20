const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const { spawn, exec } = require('child_process');
const path = require('path');
const process = require('process');

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

    // Log every request to see if the middleware is being hit
    app.use((req, res, next) => {
        console.log(`Request received: ${req.method} ${req.url}`);
        next();
    });

    // Proxy for /api-docs
    app.use('/api-docs', createProxyMiddleware({
        target: 'http://localhost:8080',  // Your C++ backend server
        changeOrigin: true,
        pathRewrite: {
            '^/oas-3.0.0.json': '/api-docs/oas-3.0.0.json', // This removes the /api-docs prefix when forwarding to the target
        },
        onProxyReq: (proxyReq, req) => {
            console.log('Proxying request for /api-docs to:', 'http://localhost:8080' + req.url);
        }
    }));
    // Proxy for /users
    app.use('/users', createProxyMiddleware({
        target: 'http://localhost:8080/users',  // Your C++ backend server
        changeOrigin: true,
        pathRewrite: {
            '^/users': '/users', // This keeps the /users prefix when forwarding to the target
        },
        onProxyReq: (proxyReq, req) => {
            console.log('Proxying request for /users to:', 'http://localhost:8080' + req.url);
        }
    }));
    // Proxy for /api
    app.use('/api', createProxyMiddleware({
        target: 'http://localhost:8080',  // Your C++ backend server
        changeOrigin: true,
        pathRewrite: {
            '^/api': '',
        },
        onProxyReq: (proxyReq, req, res) => {
            console.log('Proxying request for /api to:', 'http://localhost:8080' + req.url);
        }
    }));

    // Proxy for everything else to the React app
    app.use('/', createProxyMiddleware({
        target: 'http://localhost:3000',
        changeOrigin: true,
        onProxyReq: (proxyReq, req, res) => {
            console.log('Proxying request to React app:', 'http://localhost:3000' + req.url);
        }
    }));

    const PORT = 8888;
    app.listen(PORT, () => {
        console.log(`Proxy server running on http://localhost:${PORT}`);
    });

    process.on('exit', () => {
        backendProcess.kill();
    });
});









