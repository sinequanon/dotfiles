# Auto-label tmux panes when an agent CLI is started.
#
# The label is stored in a tmux pane option instead of the terminal title, so
# zsh/kitty OSC title updates do not overwrite it. Manual labels set with
# Prefix + P in tmux win over these auto labels.

if [[ -o interactive && -n "$TMUX" ]]; then
  autoload -Uz add-zsh-hook

  _tmux_agent_pane_label_clear_auto() {
    local source
    source=$(tmux display-message -p '#{@pane_label_source}' 2>/dev/null) || return
    if [[ "$source" == "auto" ]]; then
      tmux set-option -p @pane_label '' \; set-option -pu @pane_label_source >/dev/null 2>&1
    fi
  }

  _tmux_agent_pane_label_preexec() {
    local cmdline="${1%%$'\n'*}"
    local -a words
    words=(${(Q)${(z)cmdline}})

    local word first=""
    local -i i j
    for (( i = 1; i <= ${#words}; i++ )); do
      word="$words[$i]"
      case "$word" in
        command|exec|noglob|time|env|sudo|*=*) continue ;;
        *) first="${word:t}"; break ;;
      esac
    done

    case "$first" in
      pi|codex|claude)
        local source
        source=$(tmux display-message -p '#{@pane_label_source}' 2>/dev/null) || return
        if [[ "$source" != "manual" ]]; then
          local -a label_words
          for (( j = i + 1; j <= ${#words}; j++ )); do
            label_words+=("$words[$j]")
          done

          # If the agent was launched with an inline prompt, label the pane with
          # that prompt. Otherwise fall back to the agent name and let the manual
          # Prefix + P binding handle prompts typed after the TUI is already open.
          local label="${(j: :)label_words}"
          [[ -z "${label//[[:space:]]/}" ]] && label="$first"
          label="${label//$'\n'/ }"
          label="${label//$'\r'/ }"
          (( ${#label} > 80 )) && label="${label[1,77]}..."

          tmux set-option -p @pane_label "$label" \; set-option -p @pane_label_source auto >/dev/null 2>&1
        fi
        ;;
    esac
  }

  add-zsh-hook preexec _tmux_agent_pane_label_preexec
  add-zsh-hook precmd _tmux_agent_pane_label_clear_auto
fi
