package main

import (
	"fmt"
	"net/http"
)

func checkGeneric(u string) error {
	resp, err := http.DefaultClient.Get(u)
	if err != nil {
		return err
	}
	code := 0
	if resp != nil {
		code = resp.StatusCode
	}
	if code > 200 {
		return fmt.Errorf("unexpeccted status %d", code)
	}
	return nil

}
