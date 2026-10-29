// wasip1_wamr: a WASI preview-1 program (args, environment, stdout, fmt, strings) run by WAMR's iwasm.
package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {
	board := os.Getenv("BOARD")
	if board == "" {
		board = "unknown"
	}
	fmt.Printf("wasip1_wamr: board=%s args=%s\n", board, strings.Join(os.Args[1:], ","))
	if len(os.Args) > 1 && os.Args[1] == "fail" {
		os.Exit(3)
	}
}
