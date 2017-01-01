
`zkcmd` : Tools to Administer 'Zookeeper' Instances with Four-letter Commands

'Zookeeper' enables super-easy multi-node configuration management for distributed computing. The 'Zookeeper' instances themselves can be managed by issuing "four-letter words" over a TCP socket connection.. Methods are provided to interface with this administrative API.

The following functions are implemented inside the `zmckd` reference class:

-   `available_commands()`: Show available four-letter commands
-   `conf()`: Print details about serving configuration.
-   `connect(host = "localhost", port = 2181L, timeout = 30L)`: Connect to a Zookeeper instance.
-   `cons()`: List full connection/session details for all clients connected to this server.
-   `crst()`: Reset connection/session statistics for all conn
-   `dirs()`: Shows the total size of snapshot and log files in bytes
-   `dump()`: Lists the outstanding sessions and ephemeral nodes. This only works on the leader.
-   `envi()`: Print details about serving environment.
-   `gtmk()`: Gets the current trace mask as a 64-bit signed long value in decimal format.
-   `initialize(..., host = "localhost", port = 2181L, timeout = 30L)`: Initialize a new Zookeeper commander object.
-   `isro()`: Tests if server is running in read-only mode.
-   `ruok()`: Tests if server is running in a non-error state. The server will respond with imok if it is running. Otherwise it will not respond at all.
-   `send_cmd(cmd)`: Issue a four-letter command. Used internally but can also be used to take advantage of new commands before a package update.
-   `srst()`: Reset server statistics.
-   `srvr()`: Lists full details for the server.
-   `stat()`: Lists brief details for the server and connected clients.
-   `wchc()`: Lists detailed information on watches for the server, by session.
-   `wchp()`: Lists detailed information on watches for the server, by path.
-   `wchs()`: Lists brief information on watches for the server.

### Installation

``` r
devtools::install_git("https://gitlab.com/hrbrmstr/zkcmd.git")
```

``` r
options(width=120)
```

### Usage

``` r
library(zkcmd)

# current verison
packageVersion("zkcmd")
```

    ## [1] '0.1.0'

``` r
zk <- zkcmd$new()

zk$ruok()
```

    ## [1] TRUE

``` r
str(zk$srvr())
```

    ## List of 9
    ##  $ Zookeeper version  : chr "3.4.9-1757313, built on 08/23/2016 06:50 GMT"
    ##  $ Latency min/avg/max: chr "0/0/1006"
    ##  $ Received           : chr "399330"
    ##  $ Sent               : chr "402434"
    ##  $ Connections        : chr "3"
    ##  $ Outstanding        : chr "0"
    ##  $ Zxid               : chr "0x2904"
    ##  $ Mode               : chr "standalone"
    ##  $ Node count         : chr "28"

``` r
str(zk$conf())
```

    ## List of 8
    ##  $ clientPort       : chr "2181"
    ##  $ dataDir          : chr "/usr/local/var/run/zookeeper/data/version-2"
    ##  $ dataLogDir       : chr "/usr/local/var/run/zookeeper/data/version-2"
    ##  $ tickTime         : chr "2000"
    ##  $ maxClientCnxns   : chr "60"
    ##  $ minSessionTimeout: chr "4000"
    ##  $ maxSessionTimeout: chr "40000"
    ##  $ serverId         : chr "0"

``` r
zk$isro()
```

    ## [1] "rw"

``` r
zk$cons()
```

    ## $clients
    ## [1] "/10.1.10.163:54152[1](queued=0,recved=71404,sent=73121,sid=0x1591fe694e80102,lop=PING,est=1482445512294,to=40000,lcxid=0x1b6e,lzxid=0x2904,lresp=1483305120149,llat=0,minlat=0,avglat=0,maxlat=1006)"
    ## [2] "/10.1.10.129:50063[1](queued=0,recved=0,sent=0)"                                                                                                                                                     
    ## [3] "/127.0.0.1:59183[0](queued=0,recved=1,sent=0)"

``` r
zk$srst()
```

### Test Results

``` r
library(zkcmd)
library(testthat)

date()
```

    ## [1] "Sun Jan  1 16:12:05 2017"

``` r
test_dir("tests/")
```

    ## testthat results ========================================================================================================
    ## OK: 0 SKIPPED: 0 FAILED: 0
    ## 
    ## DONE ===================================================================================================================
