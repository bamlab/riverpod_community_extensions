## How to Contribute 🤝

If you want to report a bug, suggest an enhancement, or contribute to this project, you can leave an issue or open a pull request. Here are some guidelines to help you get started:

- Be respectful and considerate when interacting with other contributors.
- If you want to report a bug, provide a detailed description of the bug, including the steps to reproduce it.
- Clearly describe the issue or enhancement you are reporting or suggesting.
- When opening a pull request, provide a clear and concise description of the changes you have made.
- Write meaningful commit messages that accurately describe the changes made in each commit.
- Make sure to run tests and ensure that all tests are passing before submitting a pull request.

## Running Tests 🧪

This project uses [melos][melos_link] for convenience scripts such as running tests and coverage. All of these scripts can be run from any directory in the project, and are defined in the root `melos.yaml` file.

To activate melos, run the following command:

```sh
dart pub global activate melos
```

After that, to run all unit tests:

```sh
melos test
```

To run all tests and generate coverage report:

```sh
melos test:cov
```

To view the generated coverage report using [lcov][lcov_link] in your browser, run:

```sh
melos open:cov
```

If you want to reproduce the CI analyze job locally, you can run:

```sh
melos analyze
```

[melos_link]: https://melos.invertase.dev/
[lcov_link]: https://github.com/linux-test-project/lcov
