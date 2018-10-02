# Pillager
A macOS Video Downloader written in Swift and Obj.-C

![Preview Image of Pillager](/docu/pillagerpreview.png)
</br></br>

## Features: 
- [x] Download videos from the web. The full page list is visible [here.](https://rg3.github.io/youtube-dl/supportedsites.html)
- [x] You can download videos in 4 different formats (if available): mp4, webm, flv, mp3(audio only). If multiple quality versions are available, Pillager always uses the best. (improvements needed) 
- [x] You can abort downloading now. 
- [x] Download more than one video simultaneously.
- [ ] Automatic download queue. Only downloading 3 videos simultaneously, more videos in the queue wait until oldest video is finsihed downloading (better performance).
- [ ] Stop downloading process and start at later time again. 
</br></br>


## License
Pillager is licensed under the MIT-Licene. (Look in the root directory)
</br></br>

## Dependencies
Pillager needs two binaries for building: [FFmpeg](https://ffmpeg.org/) and [youtube-dl](https://rg3.github.io/youtube-dl/index.html)
</br></br>

### Youtube-dl
Youtube-dl should be included in the package. You don't need to build it yourself. If youtube-dl is not included in the source code you can get it from their [website.](https://rg3.github.io/youtube-dl/download.html).
</br></br>

### FFmpeg
You need to import a compiled version of [FFmpeg](https://ffmpeg.org/) to build the source code. I don't want to ship FFmpeg with my source code because of license problems, so please accept this workaround. FFmpeg is licenced under [GPLv2](http://www.gnu.de/documents/gpl-2.0.de.html) (or [PGPv3](http://www.gnu.de/documents/gpl.de.html)). I don't own anything about FFpmeg. All copyrights belong to their respective owners. If you want to know more about the licensing of FFmpeg look [here](https://ffmpeg.org/legal.html). If you want to distribute Pillager with FFmpeg included, then of curse you need to accept their license agreements too!
</br></br>


#### How to import FFmpeg
Just drag and drop the binary to the "Exec"-Group in Xcode. That's all, you should be able to build the application now.

![Dragndrop ffmpeg](/docu/useffmpeg.gif)
</br></br>

#### Get FFmpeg
If you don't have FFmpeg or want to build it manually yourself, here is a little workaround:

1. You need Homebrew. If you don't have Homebrew [look here](https://brew.sh/). Homebrew is a super simple package manager for macOS.
2. Open the terminal.
3. Type `brew install ffmpeg`
4. When finished type `brew --prefix ffmpeg`  
5. `cd` to displayed Path.  
6. Type `open .` Finder should open a window to the Path.  
7. Switch to subdirectory "bin" there is the "ffmpeg" executable. Now drag and drop it to Xcode.  
</br></br>

## Disclaimer
I don't give any warranty as explained in the license.

Don't download any videos you are not allowed to download with this Software. Respect the law and the rights of others. It is at your own discretion for what you use the software, therefore I do not assume any liability for any right-wing use of the software.
