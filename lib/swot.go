package main

import (
	"bufio"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/weppos/publicsuffix-go/publicsuffix"
)

const port = 9900

var whitelist, blacklist map[string]struct{}

func main() {

	log.SetFlags(log.LstdFlags | log.Lmicroseconds)
	log.Println("Starting SWOT Service...")

	whitelist = loadTLDs("swot/academic_tlds.rb")
	blacklist = loadTLDs("swot.rb")

	gin.SetMode(gin.ReleaseMode)
	engine := gin.Default()
	engine.GET("/*uri", isAcademicWrapper)
	engine.Run(fmt.Sprintf(":%v", port))
}

func loadTLDs(filename string) (list map[string]struct{}) {

	file, err := os.Open(filename)
	if err != nil {
		log.Fatalln("Error loading TLDs file:", err)
	}
	defer file.Close()

	list = make(map[string]struct{})
	var start bool

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		text := strings.TrimSpace(scanner.Text())
		if strings.HasSuffix(text, "%w(") {
			start = true
		} else if strings.HasPrefix(text, ")") {
			break
		} else if start {
			list[text] = struct{}{}
		}
	}

	if len(list) == 0 {
		log.Fatalln("Error parsing TLDs file")
	}

	return
}

func isAcademicWrapper(ctx *gin.Context) {

	if isAcademic(ctx.Params[0].Value) {
		ctx.Data(http.StatusNoContent, gin.MIMEHTML, nil)
	} else {
		ctx.AbortWithStatus(http.StatusNotFound)
	}
}

func isAcademic(uri string) bool {

	start := 0
	if i := strings.LastIndex(uri, "/"); i > start {
		start = i + 1
	}
	if i := strings.LastIndex(uri, "@"); i > start {
		start = i + 1
	}

	domain, err := publicsuffix.Domain(uri[start:])
	if err != nil {
		return false
	}

	if _, found := blacklist[domain]; found {
		return false
	}
	
	if domainName, err := publicsuffix.Parse(domain); err != nil {
		return false
	} else if _, found := whitelist[domainName.TLD]; found {
		return true
	}

	_, err = os.Stat(domainToPath(domain))
	return !os.IsNotExist(err)
}

func domainToPath(domain string) string {

	parts := strings.Split(domain, ".")

	for left, right := 0, len(parts)-1; left < right; left, right = left+1, right-1 {
		parts[left], parts[right] = parts[right], parts[left]
	}

	return fmt.Sprintf("domains/%v.txt", strings.Join(parts, "/"))
}
