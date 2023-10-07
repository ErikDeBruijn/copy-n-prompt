# 📋🤖 Copy-n-Prompt 
A [Swiftbar](https://github.com/swiftbar/SwiftBar) script to copy text that gets prompted to OpenAI's ChatGPT conversation API. The result is ready for you to paste.

Check out the [DEMO VIDEO!](https://github.com/ErikDeBruijn/copy-n-prompt/raw/main/Copy-n-prompt%20v0.2%20demo.mp4)
The demo is a bit outdated already, but still shows how it works.

# Installation
```(sh)
git clone https://github.com/ErikDeBruijn/copy-n-prompt
cd copy-n-prompt
mkdir ~/.copy-n-prompt/
cp .openai.yml.example ~/.copy-n-prompt/.openai.yaml
cp prompts.yml.example ~/.copy-n-prompt/prompts.yml
```
Edit the `~/.copy-n-prompt/.openai.yaml` and ensure it has a working OpenAI API key. Sign up at OpenAI and generate one [here](https://platform.openai.com/account/api-keys). Then copy it into the `.openai.yaml` file.

Copy or hardlink (`ln -f source target`) either `copy-n-prompt.rb` or `copy-n-prompt.py` to the Swiftbar folder.

# Ruby vs. Python3 versions
You'll notice that there are both a ruby (`.rb`) and a python (`.py`) version. I'm expecting that the Ruby version will be the most mature, going forward. I intend to maintain that one, but PRs concerning the python version are still welcome!

# Contributing
I'm not promising to actively maintain or support this, but contributions in the form of Pull requests are very welcome!

# Contributors

<a href="https://github.com/jankeesvw">
  <img alt="Jankees van Woezik" src="https://github.com/jankeesvw.png" width="50" style="border-radius: 50%;">
</a>
