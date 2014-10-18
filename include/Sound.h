/*!
 * \file include/Sound.h
 * \brief This is the audio manager Header
 *
 * \author Mongoose
 * \author xythobuz
 */

#ifndef _SOUND_H_
#define _SOUND_H_

/*!
 * \brief This is the audio manager for OpenRaider
 */
class Sound {
  public:

    typedef enum {
        SoundFlagsNone = 0,       //!< No effect
        SoundFlagsLoop = (1 << 0) //!< Enable looping during playback
    } SoundFlags;

    /*!
     * \brief Deconstructs an object of Sound
     */
    virtual ~Sound();

    /*!
     * \brief Initialize sound system
     * \returns 0 on success or < 0 error flags
     */
    virtual int initialize() = 0;

    virtual void setEnabled(bool on) = 0;

    /*!
     * \brief Set the volume
     * \param vol new source gain
     */
    virtual void setVolume(float vol) = 0;

    /*!
     * \brief Get number of registered sources
     * \returns number of registered sources
     */
    virtual unsigned long registeredSources() = 0;

    /*!
     * \brief Remove all loaded sounds
     */
    virtual void clear() = 0;

    /*!
     * \brief Move listener and repositions them
     * \param pos New position for listener
     * \param angle New orientation for listener
     */
    virtual void listenAt(float pos[3], float angle[3]) = 0;

    /*!
     * \brief Move sound source to position
     * \param source valid source id
     * \param pos new position for source
     */
    virtual void sourceAt(unsigned long source, float pos[3]) = 0;

    /*!
     * \brief Load wav file from disk
     * \param filename not NULL!
     * \param source not NULL! Returns new source ID or -1 on error.
     * \param flags set options. Use SoundFlags enum bitwise OR-ed
     * \returns 0 for no error or < 0 error flag
     */
    virtual int addFile(const char* filename, unsigned long* source, unsigned int flags) = 0;

    /*!
     * \brief Load wav file from buffer
     * \param wav not NULL! Is a valid waveform buffer!
     * \param length length of wav buffer
     * \param source not NULL! Returns new source ID or -1 on error.
     * \param flags set options. Use SoundFlags enum bitwise OR-ed
     * \returns 0 for no error or < 0 error flag
     */
    virtual int addWave(unsigned char* wav, unsigned int length, unsigned long* source,
                        unsigned int flags) = 0;

    /*!
     * \brief Play sound source
     * \param source sound source to play
     */
    virtual void play(unsigned long source) = 0;

    /*!
     * \brief Stop playing sound source
     * \param source sound source to stop
     */
    virtual void stop(unsigned long source) = 0;
};

Sound& getSound();

#endif

