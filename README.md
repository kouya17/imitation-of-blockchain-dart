# imitation-of-blockchain-dart

## Usage

```bash
dart pub get
dart pub global activate webdev
webdev build --output web:public
dart bin/back.dart --port 6565 --peer ws://dart-blockchain-test-app.herokuapp.com/ws
```

---
A sample command-line application with an entrypoint in `bin/`, library code
in `lib/`, and example unit test in `test/`.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).
