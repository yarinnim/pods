source ~/bashrc.sh
if [ "$color_prompt" = yes ]; then
  PS1='\n${debian_chroot:+($debian_chroot)}'
  PS1=$PS1'\[\e[01;32m\]\u@\h\[\e[00m\]'
  PS1=$PS1'$(get_info \w)\[\e[0m\]'
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt
