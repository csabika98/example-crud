// src/controller/StaticController.hpp
#ifndef CRUD_STATICCONTROLLER_HPP
#define CRUD_STATICCONTROLLER_HPP

#include "oatpp/web/server/api/ApiController.hpp"
#include "oatpp/macro/codegen.hpp"
#include "oatpp/macro/component.hpp"
#include "service/TemplateService.hpp"
#include <unordered_map>
#include <filesystem>
#include <fstream>

#include OATPP_CODEGEN_BEGIN(ApiController) //<- Begin Codegen

class StaticController : public oatpp::web::server::api::ApiController {
public:
    explicit StaticController(const std::shared_ptr<oatpp::web::mime::ContentMappers>& apiContentMappers)
            : oatpp::web::server::api::ApiController(apiContentMappers)
    {}
public:

    static std::shared_ptr<StaticController> createShared(
            OATPP_COMPONENT(std::shared_ptr<oatpp::web::mime::ContentMappers>, apiContentMappers) // Inject ContentMappers
    ){
        return std::make_shared<StaticController>(apiContentMappers);
    }

    ENDPOINT("GET", "/", root) {
        try {
            std::string html = TemplateService::loadTemplate("index.html");
            std::unordered_map<std::string, std::string> values = {{"value", "Hello from backend"}};
            std::string renderedHtml = TemplateService::renderTemplate(html, values);
            auto response = createResponse(Status::CODE_200, renderedHtml.c_str());
            response->putHeader(Header::CONTENT_TYPE, "text/html");
            return response;
        } catch (const std::exception& e) {
            return createResponse(Status::CODE_500, e.what());
        }
    }

    ENDPOINT("GET", "/*", staticFile,
             REQUEST(std::shared_ptr<IncomingRequest>, request)) {
        std::string rootDir = TemplateService::getProjectRootDirectory();
        std::string filePath = rootDir + std::string(*request->getPathTail());
        return serveStaticFile(filePath);
    }

private:
    std::shared_ptr<OutgoingResponse> serveStaticFile(const std::string& filePath) {
        std::ifstream file(filePath, std::ios::binary);
        if (file.is_open()) {
            std::stringstream buffer;
            buffer << file.rdbuf();
            auto response = createResponse(Status::CODE_200, buffer.str().c_str());
            std::string extension = std::filesystem::path(filePath).extension().string();
            if (extension == ".js") {
                response->putHeader("Content-Type", "application/javascript");
            } else if (extension == ".css" || extension == ".scss") {
                response->putHeader("Content-Type", "text/css");
            } else if (extension == ".json") {
                response->putHeader("Content-Type", "application/json");
            } else if (extension == ".ico") {
                response->putHeader("Content-Type", "image/x-icon");
            } else if (extension == ".txt") {
                response->putHeader("Content-Type", "text/plain");
            } else if (extension == ".html") {
                response->putHeader("Content-Type", "text/html");
            } else if (extension == ".png") {
                response->putHeader("Content-Type", "image/png");
            } else if (extension == ".jpeg" || extension == ".jpg") {
                response->putHeader("Content-Type", "image/jpeg");
            } else if (extension == ".svg") {
                response->putHeader("Content-Type", "image/svg+xml");
            }
            return response;
        } else {
            return createResponse(Status::CODE_404, "File not found");
        }
    }
};

#include OATPP_CODEGEN_END(ApiController) //<- End Codegen

#endif //CRUD_STATICCONTROLLER_HPP








