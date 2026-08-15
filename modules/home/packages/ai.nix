{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ## AI tools
    aider-chat-full
    antigravity
    antigravity-cli
    claude-code
    code-cursor
    codex
    jan
    # litellm
    llmfit
    opencode
  ];
}
