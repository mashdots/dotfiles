#!/bin/sh
write_aws_saml_credentials() {
    if [ ! -z "${ROVER_AWS_SAML_HELPER_CREDENTIALS:-}" ]; then
        mkdir -p "$HOME"/.aws
        echo "$ROVER_AWS_SAML_HELPER_CREDENTIALS" | base64 -d > "$HOME"/.aws/credentials
    fi
}

setup() {
    echo "==========================================================="
    echo "                cloning zsh-autosuggestions                "
    echo "-----------------------------------------------------------"
    ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
    git clone https://github.com/mattmc3/zshrc.d $ZSH_CUSTOM/plugins/zshrc.d
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

    echo "==========================================================="
    echo "                     installing theme                      "
    echo "-----------------------------------------------------------"
    git clone --depth=1 https://github.com/mashdots/schminitz-v2.git
    cp schminitz-v2/schminitz-v2.zsh-theme ~/.oh-my-zsh/themes/schminitz-v2.zsh-theme

    echo "==========================================================="
    echo "                       cloning pyenv                       "
    echo "-----------------------------------------------------------"
    git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv

    echo "==========================================================="
    echo "                   Setup AWS Credentials                   "
    echo "-----------------------------------------------------------"
    # Write credentials on load if possible
    write_aws_saml_credentials

    echo "==========================================================="
    echo "                       Setup Claude                        "
    echo "-----------------------------------------------------------"
    npm install -g @anthropic-ai/claude-code
    echo "export CLAUDE_CODE_USE_BEDROCK=1" >> $HOME/.zlogin
    echo "export AWS_PROFILE=dev" >> $HOME/.zlogin
    echo "export AWS_REGION=us-west-2" >> $HOME/.zlogin  
    echo "export ANTHROPIC_MODEL=us.anthropic.claude-sonnet-4-20250514-v1:0" >> $HOME/.zlogin

    echo "==========================================================="
    echo "                  generating help file                     "
    echo "-----------------------------------------------------------"
    # HELP_FILE="./lib/help.zsh"
    # touch $HELP_FILE

    # COMMON_COMMANDS="export COMMON_COMMANDS=(\n"

    # for file in lib/*.zsh; do
    #     while IFS= read -r line; do
    #         if [[ "$line" == 'function '* ]]; then
    #             function_name=$(echo "$line" | awk '{print $2}' | cut -d'(' -f1)
    #             description=$(echo "$line" | sed 's/.*# <-- //')
    #             COMMON_COMMANDS+="\n    \"    \$fg[green]$function_name\$reset_color:\\\n        $description\""
    #         fi
    #     done < "$file"
    # done

    # COMMON_COMMANDS+="\n)"

    # echo -e "$COMMON_COMMANDS" > "$HELP_FILE"

    echo "==========================================================="
    echo "                       import zshrc                        "
    echo "-----------------------------------------------------------"
    cp -r lib $HOME/.zshrc.d
    cp .zshrc $HOME/.zshrc
}

setup