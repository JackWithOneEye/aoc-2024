package viewmodel

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"strings"

	"github.com/charmbracelet/bubbles/cursor"
	"github.com/charmbracelet/bubbles/textarea"
	"github.com/charmbracelet/bubbles/viewport"
	zone "github.com/lrstanley/bubblezone"

	tea "github.com/charmbracelet/bubbletea"
	lipgloss "github.com/charmbracelet/lipgloss"
)

var (
	borderStyle = lipgloss.NewStyle().
			Padding(1).
			BorderStyle(lipgloss.DoubleBorder()).
			BorderForeground(lipgloss.Color("202"))

	headerStyle = lipgloss.NewStyle().
			Bold(true).
			Italic(true).
			Underline(true).
			Blink(true).
			Align(lipgloss.Left).
			Foreground(lipgloss.Color("#FAFAFA")).
			Background(lipgloss.Color("#04B575")).
			PaddingTop(1).
			PaddingBottom(1).
			PaddingLeft(2).
			PaddingRight(2)

	buttonStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#FFF7DB")).
			Border(lipgloss.NormalBorder()).
			Padding(1, 2).
			MarginTop(1).
			BorderForeground(lipgloss.Color("#04B575"))

	activeButtonStyle = buttonStyle.
				Foreground(lipgloss.Color("#FFF7DB")).
				Padding(1, 2).
				MarginTop(1).
				Background(lipgloss.Color("#04B575"))
)

type Payload struct {
	Day   uint8  `json:"day"`
	Part  uint8  `json:"part"`
	Input string `json:"input"`
}

type ViewModel struct {
	client *http.Client
	ta     textarea.Model
	vp     viewport.Model

	days        uint
	page        uint
	doorCursor  uint
	selectedDay uint

	solving bool
	result  string

	rw io.ReadWriter
}

type resultMsg struct {
	value string
}

func NewViewModel(client *http.Client) ViewModel {
	ta := textarea.New()
	ta.Placeholder = "Paste puzzle input..."
	ta.Focus()

	ta.Prompt = "┃ "
	ta.CharLimit = 10e6
	ta.MaxHeight = 10e6

	ta.SetWidth(30)
	ta.SetHeight(3)
	ta.FocusedStyle.CursorLine = lipgloss.NewStyle()

	vp := viewport.New(30, 0)

	return ViewModel{
		client: client,
		days:   9,
		page:   0,
		ta:     ta,
		vp:     vp,
	}
}

func (vm ViewModel) Init() tea.Cmd {
	return nil
}

func (vm ViewModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	textAreaUpdate := func() (tea.Model, tea.Cmd) {
		var cmd tea.Cmd
		vm.ta, cmd = vm.ta.Update(msg)
		return vm, cmd
	}
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		vm.vp.Width = msg.Width - 10
		vm.ta.SetWidth(msg.Width - 10)
		vm.ta.SetHeight(msg.Height / 2)
		return vm, nil
	case cursor.BlinkMsg:
		return textAreaUpdate()
	case tea.KeyMsg:
		switch msg.String() {
		case "ctrl+c", "q":
			return vm, tea.Quit
		case "left", "h":
			if vm.page == 1 {
				return textAreaUpdate()
			}
			if vm.doorCursor > 0 {
				vm.doorCursor--
			}
		case "right", "l":
			if vm.page == 1 {
				return textAreaUpdate()
			}
			if vm.doorCursor < vm.days {
				vm.doorCursor++
			}
		case "enter", " ":
			if vm.page == 0 && vm.doorCursor > 0 && vm.doorCursor <= vm.days {
				vm.selectedDay = vm.doorCursor
				vm.ta.Reset()
				vm.page = 1
				vm.result = ""
				return vm, textarea.Blink
			}
			if vm.page == 1 {
				return textAreaUpdate()
			}
		default:
			return textAreaUpdate()
		}
	case tea.MouseMsg:
		if msg.Action != tea.MouseActionRelease || msg.Button != tea.MouseButtonLeft {
			return vm, nil
		}
		if zone.Get("back").InBounds(msg) {
			vm.page = 0
		} else if zone.Get("submitA").InBounds(msg) {
			vm.solving = true
			vm.result = "..."
			return vm, func() tea.Msg {
				body, err := json.Marshal(&Payload{Day: uint8(vm.selectedDay), Part: 'a', Input: vm.ta.Value()})
				if err != nil {
					log.Fatalf("could not marshal payload: %s", err)
				}
				resp, err := vm.client.Post("http://127.0.0.1:3000/solve", "application/json", bytes.NewBuffer(body))
				if err != nil {
					log.Fatalf("part a request failed: %s", err)
				}
				defer resp.Body.Close()

				bodyBytes, err := io.ReadAll(resp.Body)
				if err != nil {
					log.Fatalf("could not read part a response body: %s", err)
				}

				res := resultMsg{value: string(bodyBytes)}
				return res
			}
		} else if zone.Get("submitB").InBounds(msg) {
			vm.solving = true
			vm.result = "..."
			return vm, func() tea.Msg {
				body, err := json.Marshal(&Payload{Day: uint8(vm.selectedDay), Part: 'b', Input: vm.ta.Value()})
				if err != nil {
					log.Fatalf("could not marshal payload: %s", err)
				}
				resp, err := vm.client.Post("http://127.0.0.1:3000/solve", "application/json", bytes.NewBuffer(body))
				if err != nil {
					log.Fatalf("part b request failed: %s", err)
				}
				defer resp.Body.Close()

				bodyBytes, err := io.ReadAll(resp.Body)
				if err != nil {
					log.Fatalf("could not read part a response body: %s", err)
				}

				res := resultMsg{value: string(bodyBytes)}
				return res
			}
		}
	case resultMsg:
		vm.solving = false
		vm.result = msg.value
	}

	return vm, nil
}

func (vm ViewModel) View() string {
	var s strings.Builder
	s.WriteString(headerStyle.Render("AOC 2024"))
	s.WriteString("\n\n")

	switch vm.page {
	case 0:
		buttons := make([]string, vm.days*2-1)
		var i int
		for d := range vm.days {
			dd := d + 1
			label := fmt.Sprintf("%d", dd)
			if dd == vm.doorCursor {
				buttons[i] = zone.Mark(label, activeButtonStyle.Render(label))
			} else {
				buttons[i] = zone.Mark(label, buttonStyle.Render(label))
			}
			i += 1
			if i < len(buttons)-1 {
				buttons[i] = " "
				i += 1
			}
		}

		doors := lipgloss.JoinHorizontal(lipgloss.Top, buttons...)
		s.WriteString(doors)
	case 1:
		s.WriteString(fmt.Sprintf("%s\n%s\n\n", vm.vp.View(), vm.ta.View()))

		buttons := lipgloss.JoinHorizontal(lipgloss.Top,
			zone.Mark("submitA", buttonStyle.Render("SUBMIT A")),
			" ",
			zone.Mark("submitB", buttonStyle.Render("SUBMIT B")),
			" ",
			zone.Mark("back", buttonStyle.Render("BACK")),
			" ",
			vm.result,
		)
		s.WriteString(buttons)
	}

	return zone.Scan(borderStyle.Render(s.String()))
}
