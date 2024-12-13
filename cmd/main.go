package main

import (
	"fmt"
	"net/http"
	"os"

	"github.com/JackWithOnEye/aoc-2024/internal/viewmodel"
	tea "github.com/charmbracelet/bubbletea"
	zone "github.com/lrstanley/bubblezone"
)

func main() {
	client := &http.Client{}
	zone.NewGlobal()
	p := tea.NewProgram(viewmodel.NewViewModel(client), tea.WithAltScreen(), tea.WithMouseCellMotion())
	if _, err := p.Run(); err != nil {
		fmt.Printf("Alas, there's been an error: %v", err)
		os.Exit(1)
	}
}
