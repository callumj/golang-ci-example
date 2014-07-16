package app

import (
	"fmt"
	"github.com/callumj/example/utils"
)

func Run(args []string) {
	fmt.Printf("VERSION: %s\r\n", utils.AppVersion)
	fmt.Printf("Args: %v\r\n", args)
}
