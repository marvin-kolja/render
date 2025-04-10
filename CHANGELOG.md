## 0.0.1

* TODO: Describe initial release.

## 0.0.2

* Initial Working support for IOS, ANDROID, MACOS

## 0.0.3

* Updated readme
* formated

## 0.0.4

* Spelling and link correction

## 0.0.5

* legal description updated

## 0.0.6

* readme: comparison

## 0.0.7

* readme: layout correction

## 0.0.8

* ffmpeg error log
* same-size frame error checking

## 0.0.9

* safe size frames (dividable by 2)
* pixelRatio note

## 0.1.0

* support for cropping on audio source

## 0.1.1

* time capture bug resolved (laggy outcome)
* proper session disposal

## 0.1.2

* error on closing application during active render session
* doc update

## 0.1.3

* window update (flutter 3.1) flutterView

## 0.2.0

* BREAKING CHANGE: replaced ffmpeg dependency in favor of native encoding. This resulted in changes to the API. Thus, certain options and formats have been changed or removed.
* BREAKING CHANGE: replaced audio render options with pcm audio stream. Instead of passing an audio file, you can pass a stream of pcm audio data. The audio stream will be cut into the correct chunks and passed to the native encoder.
* BREAKING CHANGE: single image encoding is not implemented at the moment, thus, single image capture does not work.

## 0.2.1

* fix encoder setup is not awaiting leading to null pointer exceptions

## 0.2.2

* add stack trace to `RenderError`
