#!/bin/bash

initialize_game() {
  width=20
  height=10
  snake_x=$((width / 2))
  snake_y=$((height / 2))
  snake_dir="right"
  snake_body=("0,$snake_x,$snake_y")
  fruit_x=0
  fruit_y=0
  score=0
  generate_fruit
}

generate_fruit() {
  fruit_x=$((RANDOM % (width - 2) + 1))
  fruit_y=$((RANDOM % (height - 2) + 1))
}

check_collision() {
  for ((i = 1; i < ${#snake_body[@]}; i++)); do
    IFS=',' read -ra coords <<< "${snake_body[$i]}"
    if ((snake_x == coords[1] && snake_y == coords[2])); then
      return 1
    fi
  done
  return 0
}

game_over_prompt() {
  echo "Game Over! Your score is $score"
  sleep 1  # Sleep for 1 second
  # Ignore any input during sleep
  read -t 1 -n 1000 -s
  read -p "Press 'r' and Enter to retry, 'q' and Enter to quit: " choice
  case "$choice" in
    "q")
      exit
      ;;
    *)
      initialize_game
      ;;
  esac
}

initialize_game

while true; do
  clear

  for ((i = 0; i < height; i++)); do
    for ((j = 0; j < width; j++)); do
      if ((i == 0 || i == height - 1 || j == 0 || j == width - 1)); then
        echo -n "#"
      else
        found=false
        for segment in "${snake_body[@]}"; do
          IFS=',' read -ra coords <<< "$segment"
          if ((i == coords[2] && j == coords[1])); then
            if ((coords[0] == 1)); then
              echo -n "O"
            else
              echo -n "0"
            fi
            found=true
            break
          fi
        done
        if [[ $found == false ]]; then
          if ((i == fruit_y && j == fruit_x)); then
            echo -n "*"
          else
            echo -n " "
          fi
        fi
      fi
    done
    echo
  done

  echo "Score: $score"

  read -s -t 0.1 -n 1 input

  case "$input" in
    "w")
      snake_dir="up"
      ;;
    "s")
      snake_dir="down"
      ;;
    "a")
      snake_dir="left"
      ;;
    "d")
      snake_dir="right"
      ;;
  esac

  case "$snake_dir" in
    "up")
      snake_y=$((snake_y - 1))
      ;;
    "down")
      snake_y=$((snake_y + 1))
      ;;
    "left")
      snake_x=$((snake_x - 1))
      ;;
    "right")
      snake_x=$((snake_x + 1))
      ;;
  esac

  if ((snake_x < 1 || snake_x >= width - 1 || snake_y < 1 || snake_y >= height - 1)); then
    game_over_prompt
  fi

  if ((snake_x == fruit_x && snake_y == fruit_y)); then
    score=$((score + 1))
    generate_fruit
  else
    check_collision
    if [[ $? -eq 1 ]]; then
      game_over_prompt
    fi

    snake_body=("${snake_body[@]:0:${#snake_body[@]}-1}")
  fi

  snake_body=("0,$snake_x,$snake_y" "${snake_body[@]}")

  sleep 0.1
done
