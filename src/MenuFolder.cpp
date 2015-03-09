/*!
 * \file src/MenuFolder.cpp
 * \brief File-Explorer like menu
 *
 * \author xythobuz
 */

#include "global.h"
#include "Game.h"
#include "loader/Loader.h"
#include "Log.h"
#include "Render.h"
#include "RunTime.h"
#include "MenuFolder.h"
#include "system/Font.h"
#include "system/Window.h"

MenuFolder::MenuFolder() {
    mCursor = 0;
    mMin = 0;
    mapFolder = nullptr;
    hiddenState = false;
    dialogState = false;
    visible = false;
}

MenuFolder::~MenuFolder() {
    delete mapFolder;
    mapFolder = nullptr;
}

int MenuFolder::initialize() {
    return init(RunTime::getPakDir());
}

int MenuFolder::init(std::string s) {
    return init(new Folder(s));
}

int MenuFolder::init(Folder* folder, bool filter) {
    if (mapFolder != nullptr)
        delete mapFolder;

    mapFolder = folder;
    mMin = mCursor = 0;

    if (filter) {
        mapFolder->executeRemoveFiles([](File & f) {
            // Filter files based on file name
            if ((f.getName().length() > 4)
                && (f.getName().compare(f.getName().length() - 4, 4, ".phd") != 0)
                && (f.getName().compare(f.getName().length() - 4, 4, ".psx") != 0)
                && (f.getName().compare(f.getName().length() - 4, 4, ".tub") != 0)
                && (f.getName().compare(f.getName().length() - 4, 4, ".tr2") != 0)
                && (f.getName().compare(f.getName().length() - 4, 4, ".tr4") != 0)
                && (f.getName().compare(f.getName().length() - 4, 4, ".trc") != 0)) {
                return true; // delete file from list
            }

            // Check maps for validity
            Loader::LoaderVersion version = Loader::checkFile(f.getPath());
            if (version == Loader::TR_UNKNOWN) {
                Log::get(LOG_ERROR) << "Error: pak file '" << f.getName().c_str()
                                    << "' invalid" << Log::endl;
                return true; // delete file from list
            }

            return false; // keep file on list
        });
    }

    if ((mapFolder->fileCount() + mapFolder->folderCount()) > 0)
        mCursor = 1; // Don't select ".." by default

    return 0;
}

void MenuFolder::display() {
    if (!visible)
        return;

    Font::drawTextCentered(0, 10, 1.2f, textColor, Window::getSize().x, VERSION);

    // Draw half-transparent overlay
    glm::vec4 color(0.0f, 0.0f, 0.0f, 0.75f);
    Render::drawTexture(0.0f, 0.0f, Window::getSize().x, Window::getSize().y,
                        color, TEXTURE_WHITE, TextureStorage::SYSTEM);

    // Draw heading
    Font::drawTextCentered(0, 10, 1.2f, textColor, Window::getSize().x, VERSION);

    // Estimate displayable number of items
    int items = (Window::getSize().y - 60) / 25;

    // Print list of "..", folders, files
    for (long i = mMin; (i < (mMin + items))
         && (i < (mapFolder->folderCount() + mapFolder->fileCount() + 1)); i++) {
        if (i == 0) {
            Font::drawText(25, 50, 0.75f, (mCursor == i) ? selectedColor : textColor, "..");
        } else {
            Font::drawText(25, (unsigned int)(50 + (25 * (i - mMin))), 0.75f,
                           (mCursor == i) ? selectedColor : textColor,
                           ((i - 1) < mapFolder->folderCount()) ?
                           (mapFolder->getFolder(i - 1).getName() + "/")
                           : mapFolder->getFile(i - 1 - mapFolder->folderCount()).getName());
        }
    }

    displayDialog();
}

void MenuFolder::loadOrOpen() {
    if (mCursor == 0) {
        if (init(mapFolder->getParent().getPath()) != 0) {
            showDialog("Error reading parent folder!", "OK", "");
        }
    } else if ((mCursor - 1) < mapFolder->folderCount()) {
        if (init(mapFolder->getFolder(mCursor - 1).getPath()) != 0) {
            showDialog("Error reading subfolder!", "OK", "");
        }
    } else {
        showDialog("Loading...", "OK");
        renderFrame();
        int error = Game::loadLevel(mapFolder->getFile((unsigned long)mCursor
                                    - 1 - mapFolder->folderCount()).getPath().c_str());
        ackDialog();
        if (error == 0) {
            visible = false;
        } else {
            std::ostringstream err;
            err << "Error loading map: " << error << "!";
            showDialog(err.str(), "OK", "");
        }
    }
}

void MenuFolder::handleKeyboard(KeyboardButton key, bool pressed) {
    if (handleKeyboardDialog(key, pressed))
        return;

    if (!pressed)
        return;

    assert(mapFolder != nullptr);
    int items = (Window::getSize().y - 60) / 25;

    if (key == upKey) {
        if (mCursor > 0)
            mCursor--;
        else
            mCursor = (long)(mapFolder->folderCount() + mapFolder->fileCount());
    } else if (key == downKey) {
        if (mCursor < (long)(mapFolder->folderCount() + mapFolder->fileCount()))
            mCursor++;
        else
            mCursor = 0;
    } else if (key == enterKey) {
        loadOrOpen();
    } else if (key == dotKey) {
        hiddenState = !hiddenState;
        init(mapFolder->getPath());
    }

    if (mCursor > (mMin + items - 1)) {
        mMin = mCursor - items + 1;
    } else if (mCursor < mMin) {
        mMin = mCursor;
    }
}

void MenuFolder::handleMouseClick(unsigned int x, unsigned int y, KeyboardButton button,
                                  bool released) {
    if (handleMouseClickDialog(x, y, button, released))
        return;

    int items = (Window::getSize().y - 60) / 25;

    if (released || (button != leftmouseKey))
        return;

    if ((y >= 50) && (y <= (unsigned int)(50 + (25 * items)))
        && ((mMin + (y / 25)) <= (mapFolder->folderCount() + mapFolder->fileCount() + 2))) {
        y -= 50;
        if (mCursor == (mMin + (y / 25)))
            loadOrOpen();
        else
            mCursor = mMin + (y / 25);
    }
}

void MenuFolder::handleMouseScroll(int xrel, int yrel) {
    if (handleMouseScrollDialog(xrel, yrel))
        return;

    assert((xrel != 0) || (yrel != 0));
    assert(mapFolder != nullptr);
    int items = (Window::getSize().y - 60) / 25;

    if ((mapFolder->folderCount() + mapFolder->fileCount() + 1) > items) {
        if (yrel < 0) {
            if (mMin < (mapFolder->folderCount() + mapFolder->fileCount() + 1 - items))
                mMin++;
        } else if (yrel > 0) {
            if (mMin > 0)
                mMin--;
        }

        if (mCursor < mMin) {
            mCursor = mMin;
        } else if (mCursor > (mMin + items - 1)) {
            mCursor = mMin + items - 1;
        }
    }
}

