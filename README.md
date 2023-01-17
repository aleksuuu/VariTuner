# VariTuner

A microtonal tuner and tone generator for iOS. The development is still ongoing. 

## Known Issues

- ioData.mNumberBuffers=2, ASBD::NumberChannelStreams(output.GetStreamFormat())=1; kAudio_ParamError
	- from AU (0x103361bf0): auou/rioc/appl, render err: -50
	- [https://stackoverflow.com/questions/51836792/audiounitrender-error-50-meaning](https://stackoverflow.com/questions/51836792/audiounitrender-error-50-meaning)
