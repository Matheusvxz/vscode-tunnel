# VSCode Tunnel [![Google Cloud][gcp-img]][gcp]

<img src="https://code.visualstudio.com/assets/images/code-stable.png" align="right" alt="VSCode Tunnel logo" width="120" height="120">

VSCode Tunnel is a simple repository designed to streamline the process of adding startup scripts to Google Cloud Compute Engines to start a VSCode tunnel.

* **Effortless Setup.** Quickly configure your Google Cloud Compute Engine to start a VSCode tunnel.
* **Secure.** Leverages GitHub authentication for token generation.
* **Lightweight.** Minimal setup required to get started.

## How It Works

1. **Generate a Token**
   Run the following command to generate a token:
   ```bash
   code tunnel user login --provider github
   ```
   Copy the token found in:
   ```
   ~/.vscode/cli/token.json
   ```

2. **Add Startup Script**
   Use the provided startup script located in the `startup/` directory to configure your Google Cloud Compute Engine.

## Repository Structure

```plaintext
README.md
startup/
    compute_engine.sh

```

## Contributing

We welcome contributions! Feel free to submit issues or pull requests to improve this repository.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

[gcp-img]: https://upload.wikimedia.org/wikipedia/commons/5/5f/Google_Cloud_logo.svg
[gcp]: https://cloud.google.com/

