package main

import (
	// "context"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
)

var (
	statePath = filepath.Join("/", "run", "self", "state")
)

func init() {
}

func writeState(state string) {
	if err := ioutil.WriteFile(statePath, []byte(state+"\n"), 0644); err != nil {
		log.Fatalf("entrypoint: failed to update state file: %v", err)
	}
}

func main() {
	log.Printf("entrypoint: starting")

	if err := checkRegularAccess(statePath); err != nil {
		log.Fatalf("entrypoint: failed to verify state file: %v", err)
	}

	log.Printf("entrypoint: staging")

	writeState("staging")

	// ctx, cancel := context.WithCancel(context.Background())
	// ctx := context.Background()

	success := make(chan int, 1)
	failed := make(chan error, 1)

	go func() {
		// cmd := exec.CommandContext(ctx, "/docker-container-dns")
		cmd := exec.Command("/docker-container-dns")

		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr

		err := cmd.Run()
		if err != nil {
			failed <- err
			return
		}

		success <- 0
	}()

	writeState("running")

	select {
	case <-success:
		log.Printf("entrypoint: done")
	case err := <-failed:
		log.Printf("entrypoint: execution error: %v", err)
	}

	log.Printf("entrypoint: terminating")

	writeState("exited")
}
