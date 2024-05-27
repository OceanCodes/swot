module github.com/OceanCodes/swot

go 1.16

require (
	github.com/gin-gonic/gin v1.3.0
	github.com/weppos/publicsuffix-go v0.4.0
	gopkg.in/check.v1 v1.0.0-20201130134442-10cb98267c6c // indirect
)

replace (
	github.com/gin-gonic/gin => github.com/gin-gonic/gin v1.9.1
	golang.org/x/net => golang.org/x/net v0.23.0
	golang.org/x/sys => golang.org/x/sys v0.0.0-20220412211240-33da011f77ad
	golang.org/x/text => golang.org/x/text v0.3.8
	gopkg.in/yaml.v2 => gopkg.in/yaml.v2 v2.2.8
)
