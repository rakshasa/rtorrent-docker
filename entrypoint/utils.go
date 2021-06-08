package main

import (
	"fmt"
	"os"
	"path/filepath"

	"golang.org/x/sys/unix"
)

func checkDirectoryExistsAndAccess(path string) (bool, error) {
	fileInfo, err := checkAccessAndFileInfo(path, unix.R_OK|unix.W_OK|unix.X_OK)
	if err != nil {
		if !os.IsNotExist(err) {
			return false, err
		}

		return false, nil
	}
	if !fileInfo.Mode().IsDir() {
		return false, fmt.Errorf("is not a directory: %s", path)
	}

	return true, nil
}

func checkDirectoryAccess(path string) error {
	exists, err := checkDirectoryExistsAndAccess(path)
	if err != nil {
		return err
	}
	if !exists {
		return fmt.Errorf("does not exist: %s", path)
	}

	return nil
}

func checkRegularExistsAndAccess(path string) (bool, error) {
	fileInfo, err := checkAccessAndFileInfo(path, unix.R_OK|unix.W_OK)
	if err != nil {
		if !os.IsNotExist(err) {
			return false, err
		}

		return false, nil
	}
	if !fileInfo.Mode().IsRegular() {
		return false, fmt.Errorf("is not a regular file: %s", path)
	}

	return true, nil
}

func checkRegularAccess(path string) error {
	exists, err := checkRegularExistsAndAccess(path)
	if err != nil {
		return err
	}
	if !exists {
		return fmt.Errorf("does not exist: %s", path)
	}

	return nil
}

func checkAccessAndFileInfo(path string, mode uint32) (os.FileInfo, error) {
	fileInfo, err := os.Stat(path)
	if err != nil {
		if !os.IsNotExist(err) {
			return nil, fmt.Errorf("stat failed: %v", err)
		}

		return nil, err
	}
	if err = unix.Access(path, mode); err != nil {
		return nil, fmt.Errorf("insufficient permission: %v", err)
	}

	return fileInfo, nil
}

func checkParentDirectoryAndMkdir(path string) error {
	dirPath := filepath.Dir(path)

	exists, err := checkDirectoryExistsAndAccess(dirPath)
	if err != nil {
		return err
	}
	if !exists {
		return fmt.Errorf("does not exist: %s", dirPath)
	}

	if err := os.Mkdir(path, os.ModePerm); err != nil {
		return err
	}

	return nil
}
