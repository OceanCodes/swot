package main

import (
	"testing"
)

func TestIsAcademic(t *testing.T) {

	whitelist = loadTLDs("swot/academic_tlds.rb")
	blacklist = loadTLDs("swot.rb")

	if !isAcademic("lreilly@stanford.edu") { t.Fatal() }
	if !isAcademic("lreilly@strath.ac.uk") { t.Fatal() }
	if !isAcademic("lreilly@soft-eng.strath.ac.uk") { t.Fatal() }
	if !isAcademic("pedro@ugr.es") { t.Fatal() }
	if !isAcademic("lee@uottawa.ca") { t.Fatal() }
	if !isAcademic("lreilly@cs.strath.ac.uk") { t.Fatal() }
	if !isAcademic("harvard.edu") { t.Fatal() }
	if !isAcademic("www.harvard.edu") { t.Fatal() }
	if !isAcademic("http://www.harvard.edu") { t.Fatal() }
	if !isAcademic("http://www.stanford.edu") { t.Fatal() }

	if isAcademic("lee@leerilly.net") { t.Fatal() }
	if isAcademic("http://www.github.com") { t.Fatal() }
	if isAcademic("http://www.rangers.co.uk") { t.Fatal() }
}
