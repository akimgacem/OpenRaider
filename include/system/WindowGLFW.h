/*!
 * \file include/system/WindowGLFW.h
 * \brief GLFW Windowing Implementation
 *
 * \author xythobuz
 */

#ifndef _WINDOW_GLFW_H_
#define _WINDOW_GLFW_H_

#include <string>
#include <glm/gtc/type_precision.hpp>

struct GLFWwindow;

class WindowGLFW {
  public:
    static int initialize();
    static void eventHandling();
    static void swapBuffers();
    static void shutdown();

    static void setSize(glm::i32vec2 s);
    static glm::i32vec2 getSize() { return size; }

    static void setFullscreen(bool f);
    static bool getFullscreen() { return fullscreen; }

    static void setMousegrab(bool g);
    static bool getMousegrab() { return mousegrab; }

    static void setTextInput(bool t);
    static bool getTextInput() { return textinput; }

    static void setClipboard(const char* s);
    static const char* getClipboard();

    static void inputPositionCallback(int x, int y);

    static std::string getVersion(bool linked);

  private:
    static void errorCallback(int error, const char* desc);
    static void sizeCallback(GLFWwindow* w, int width, int height);
    static void cursorCallback(GLFWwindow* w, double xpos, double ypos);
    static void keyCallback(GLFWwindow* w, int key, int scancode, int action, int mods);
    static void charCallback(GLFWwindow* w, unsigned int codepoint);
    static void buttonCallback(GLFWwindow* w, int button, int action, int mods);
    static void scrollCallback(GLFWwindow* w, double xoffset, double yoffset);

    static KeyboardButton convertAsciiButton(int key);

    static glm::i32vec2 size;
    static bool fullscreen;
    static bool mousegrab;
    static bool textinput;
    static GLFWwindow* window;
    static int lastMouseX, lastMouseY;
    static bool modShift;
    static bool modControl;
    static bool modAlt;
    static bool modSuper;
};

#endif

