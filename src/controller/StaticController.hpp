// src/controller/StaticController.hpp
#ifndef CRUD_STATICCONTROLLER_HPP
#define CRUD_STATICCONTROLLER_HPP

#include "oatpp/web/server/api/ApiController.hpp"
#include "oatpp/json/ObjectMapper.hpp"
#include "oatpp/macro/codegen.hpp"
#include "oatpp/macro/component.hpp"
#include "service/TemplateService.hpp"
#include <unordered_map>

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
            std::string html = TemplateService::loadTemplate("example.html");
            std::unordered_map<std::string, std::string> values = {{"value", "Hello from backend"}};
            std::string renderedHtml = TemplateService::renderTemplate(html, values);
            auto response = createResponse(Status::CODE_200, renderedHtml.c_str());
            response->putHeader(Header::CONTENT_TYPE, "text/html");
            return response;
        } catch (const std::exception& e) {
            return createResponse(Status::CODE_500, e.what());
        }
    }

};

#include OATPP_CODEGEN_END(ApiController) //<- End Codegen

#endif //CRUD_STATICCONTROLLER_HPP


