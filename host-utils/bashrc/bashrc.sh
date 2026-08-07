#! /bin/bash
#
# Reset
Color_Off="\e[0m"       # Text Reset

# Regular Colors
Gray="\e[0;30m"
Red="\e[0;91m"          # Red
Green="\e[0;92m"        # Green
Yellow="\e[0;93m"       # Yellow
Blue="\e[0;94m"         # Blue
White="\e[0;97m"        # White
Cyan="\e[0;36m"

# Bold
BBlack="\e[1;30m"       # Black
BBlue="\e[1;34m"        # Blue
BPurple="\e[1;35m"      # Purple
BWhite="\e[1;37m"       # White

# Background
On_Red="\e[101m"         # Red
On_Green="\e[102m"       # Green
On_Yellow="\e[103m"      # Yellow
On_Blue="\e[104m"        # Blue
On_White="\e[107m"       # White
On_Gray="\e[40m"
On_Cyan="\e[46m"

IFS=' ' read -ra TextColors <<< "$BWhite $BBlack $BBlack $BBlack $BBlue $BPurple"
IFS=' ' read -ra BgColors <<< "$On_Red $On_Green $On_Yellow $On_Blue $On_White $On_Blue"
IFS=' ' read -ra ArrowColors <<< "$Red $Green $Yellow $Blue $White $Blue"

git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

Arrow=""

print_text() {
  CI=$2
  isLast=$3
  local textColor=${TextColors[$CI]}
  local bgColor=${BgColors[$CI]}
  local aColor=${ArrowColors[$CI]}
  local NI=$((CI + 1))
  if [ "$CI" -lt 2 ]; then
    NI=2
  fi
  nextBgColor=${BgColors[$NI]}
  if [[ $isLast -eq 1 ]]; then
    nextBgColor=""
  fi
  echo -n -e "$textColor$bgColor$1$aColor$nextBgColor$Color_Off"
}

get_git_submodules() {
  # local modules=($(git submodule status 2>/dev/null | awk '{ print $2 }'))
  mapfile -t modules < <(git submodule status 2>/dev/null | awk '{ print $2 }')
  echo "${modules[@]}"
}

git_submodule() {
  modules=($(get_git_submodules))
  length=${#modules[@]}
  isLast=0

  if [ "$length" -gt 0 ]; then
    for (( i=0; i < ${#modules[@]}; i++ )); do
      module=${modules[$i]}
      if [ $i -eq $((length - 1)) ]; then
        isLast=1
      fi
      print_text "   $module " "$((i + 2))" "$isLast"
    done
  fi
}

get_size() {
  # echo -e -n "$BWhite$On_Cyan   $(du -khs 2>/dev/null | awk '{print $1}')"
  # echo -e -n " $Color_Off$Cyan$On_Gray$Arrow$Color_Off"
  echo ""
}


git_info() {
  branch=$(git_branch)
  if [ -n "$branch" ]; then
    modules=($(get_git_submodules))
    # mapfile -t modules < <(get_git_submodules)
    isLast=0
    if [ "${#modules[@]}" -eq 0 ]; then
      isLast=1
    fi

    if [ "$(git status --porcelain 2>/dev/null | wc -l)" -eq 0 ]; then
      print_text '\n'"  $branch $Color_Off" 1 $isLast
    else
      print_text '\n'"  $branch $Color_Off" 0 $isLast
    fi
  fi
  echo "\033[0m\033[K" 
}

get_info()
{
  CWD=$(echo "$1" | sed 's/\/home\/yarin/~/g')
  CWD="$BWhite$On_Gray $CWD $Color_Off$Gray$Arrow$Color_Off"
  echo -e -n "$(git_info)\e[0m$Color_Off$(git_submodule)$Color_Off"
  echo -e -n "\n$(get_size)$CWD\n  "
}
