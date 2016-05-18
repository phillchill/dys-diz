Dys Diz
---

# Media

The `media/` folder contains images (exported frames) and recorded videos of Dys Diz letters.

## Exporting frames

Frames as exported using [FFmpeg](https://ffmpeg.org/).
On Mac OSX FFmpeg can be installed via `brew` by running in terminal:

`brew install ffmpeg`

To export frames using FFmpeg run in terminal:

`ffmpeg -i NAME_OF_VIDEO_FILE -vf fps=3 START_OF_IMAGE_FILENAMES-%d.png`

## Folder structure

	media
	├── A
	│   ├── landscape
	│   │   ├── images
	│   │   └── video
	│   └── portrait
	│       ├── images
	│       └── video
	├── B
	│   ├── landscape
	│   │   ├── images
	│   │   └── video
	│   └── portrait
	│       ├── images
	│       └── video
	etc...


