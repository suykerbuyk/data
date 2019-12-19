package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"github.com/wI2L/jettison"
	"io/ioutil"
	"os"
)

func main() {
	textPtr := flag.String("text", "my_text", "Something texty")
	flag.Parse()
	fmt.Println("test flag: %s", *textPtr)
	fmt.Println(flag.Args())
	jsonFile, err := os.Open("librbd-lr02u27-J24-write-32k.fio.json")
	if err != nil {
		panic(err)
	}
	defer jsonFile.Close()
	byteValue, err := ioutil.ReadAll(jsonFile)
	if err != nil {
		panic(err)
	}
	var result FioData
	json.Unmarshal([]byte(byteValue), &result)
	jsonOut, err := jettison.Marshal(result)
	if err != nil {
		panic(err)
	}
	os.Stdout.Write(jsonOut)
}
