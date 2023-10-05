# copy-n-prompt
A script to copy text that gets prompted to OpenAI's ChatGPT conversation API. The result is ready for you to paste.

Check out the [DEMO VIDEO!](https://github.com/ErikDeBruijn/copy-n-prompt/raw/main/Copy-n-prompt%20v0.2%20demo.mp4)

# Installation
```(sh)
git clone https://github.com/ErikDeBruijn/copy-n-prompt
cd copy-n-prompt
mkdir ~/.copy-n-prompt/
cp ~/.copy-n-prompt/.openai.yml.example ~/.copy-n-prompt/.openai.yaml
cp ~/.copy-n-prompt/prompts.yml ~/.copy-n-prompt/
```
Edit the `~/.copy-n-prompt/.openai.yaml` and ensure it has a working OpenAI API key. Sign up at OpenAI and generate one [here](https://platform.openai.com/account/api-keys). Then copy it into the `.openai.yaml` file.

# Contributing
I'm not going to actively maintain or support this, but contributions in the form of Pull requests are very welcome!
