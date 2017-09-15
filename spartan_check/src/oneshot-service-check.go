package main

import (
        "fmt"
        "net"
        "time"
)

const (
        ready_spartan_dns_name = "ready.spartan"
        sleep_time_seconds     = 5
)

func spartanchecker() {
    for {
        spartan_result, spartan_err := net.LookupHost(ready_spartan_dns_name)
        if spartan_err == nil {
            fmt.Print("Spartan is now ready: ")
            fmt.Println(spartan_result)
            break
        }
        fmt.Println("waiting for spartan to get ready...")
        time.Sleep(sleep_time_seconds * time.Second)
    }
}

func main() {
    spartanchecker()
}
