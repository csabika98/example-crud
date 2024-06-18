// src/service/TemplateService.hpp
#ifndef TEMPLATESERVICE_HPP
#define TEMPLATESERVICE_HPP

#include <string>
#include <fstream>
#include <sstream>
#include <iostream>
#include <unordered_map>
#include <filesystem>

class TemplateService {
public:
    static std::string getProjectRootDirectory() {

        std::filesystem::path currentPath = std::filesystem::current_path();


        std::filesystem::path projectRoot = currentPath.parent_path();


        std::cout << "Current working directory: " << currentPath << std::endl;
        std::cout << "Assumed project root directory: " << projectRoot << std::endl;

        return projectRoot.string();
    }

    static std::string loadTemplate(const std::string& templateName) {
        std::string rootDir = getProjectRootDirectory();
        std::string filePath = rootDir + "/src/templates/" + templateName;


        std::cout << "Trying to load template file: " << filePath << std::endl;

        std::ifstream file(filePath);
        if (!file.is_open()) {
            throw std::runtime_error("Could not open template file: " + templateName);
        }

        std::stringstream buffer;
        buffer << file.rdbuf();
        return buffer.str();
    }

    static std::string renderTemplate(const std::string& templateStr, const std::unordered_map<std::string, std::string>& values) {
        std::string result = templateStr;
        for (const auto& pair : values) {
            std::string placeholder = "${" + pair.first + "}";
            size_t pos = result.find(placeholder);
            while (pos != std::string::npos) {
                result.replace(pos, placeholder.length(), pair.second);
                pos = result.find(placeholder, pos + pair.second.length());
            }
        }
        return result;
    }
};

#endif // TEMPLATESERVICE_HPP
