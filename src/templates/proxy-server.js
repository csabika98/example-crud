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


    app.use('/api', createProxyMiddleware({
        target: 'http://localhost:8080',  // Your C++ backend server
        changeOrigin: true,
        pathRewrite: {
            '^/api': '',
        },
    }));


    app.use('/', createProxyMiddleware({
        target: 'http://localhost:3000',
        changeOrigin: true,
    }));

    const PORT = 8888;
    app.listen(PORT, () => {
        console.log(`Proxy server running on http://localhost:${PORT}`);
    });


    process.on('exit', () => {
        backendProcess.kill();
    });
});



