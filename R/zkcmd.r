#' Reference class for sending four-letter commands to zookeeper instances
#'
#' @note Currently supports NIO Zookeeper instances.
#'
#' @import methods
#' @export zkcmd
#' @exportClass zkcmd
#' @examples \dontrun{
#' zk <- zkcmd$new()
#' zk$ruok()
#' }
zkcmd <- setRefClass(

  Class="zkcmd",

  fields=list(
    host="character",
    port="integer",
    timeout="integer"
  ),

  methods=list(

    initialize=function(..., host="localhost", port=2181L, timeout=30L) {
      "Initialize a new Zookeeper commander object."
      host <<- host ; port <<- port ; timeout <<- timeout; callSuper(...)
    },

    available_commands=function() {
      "Show available four-letter commands"
      return(sort(c("conf", "envi", "stat", "srvr", "whcs", "wchc", "wchp", "mntr",
                    "cons", "crst", "srst", "dump", "ruok", "dirs", "isro", "gtmk")))
    },

    connect=function(host="localhost", port=2181L, timeout=30L) {
      "Connect to a Zookeeper instance."
      .self$host <- host ; .self$port <- port ; .self$timeout <- timeout
    },

    conf=function() {
      "Print details about serving configuration."
      res <- .self$send_cmd("conf")
      res <- stringi::stri_split_fixed(res, "=", 2, simplify=TRUE)
      as.list(setNames(res[,2], res[,1]))
    },

    envi=function() {
      "Print details about serving environment."
      res <- .self$send_cmd("envi")
      res <- stringi::stri_split_fixed(res[-1], "=", 2, simplify=TRUE)
      as.list(setNames(res[,2], res[,1]))
    },

    stat=function() {
      "Lists brief details for the server and connected clients."
      res <- .self$send_cmd("stat")
      version <- stri_replace_first_regex(res[1], "^Zoo.*: ", "")
      res <- res[-(1:2)]
      sep <- which(res=="")
      clients <- stri_trim(res[1:(sep-1)])
      zstats <- stringi::stri_split_fixed(res[(sep+1):length(res)], ": ", 2, simplify=TRUE)
      zstats <- as.list(setNames(zstats[,2], zstats[,1]))
      list(version=version, clients=clients, stats=zstats)
    },

    srvr=function() {
      "Lists full details for the server."
      res <- .self$send_cmd("srvr")
      zstats <- stringi::stri_split_fixed(res, ": ", 2, simplify=TRUE)
      as.list(setNames(zstats[,2], zstats[,1]))
    },

    wchs=function() {
      "Lists brief information on watches for the server."
      res <- .self$send_cmd("wchs")
      conn_path <- stri_match_first_regex(res[1], "^([[:digit:]]+) connections watching ([[:digit:]]+) paths")
      tot_watch <- stri_match_first_regex(res[2], "Total watches:([[:digit:]]+)")
      list(connections_watching=conn_path[,2], paths=conn_path[,3], total_watches=tot_watch[,2])
    },

    wchc=function() {
      "Lists detailed information on watches for the server, by session."
      stri_trim(.self$send_cmd("wchc")) %>% discard(`==`, "") -> res
      setNames(list(res[2:length(res)]), res[1])
    },

    wchp=function() {
      "Lists detailed information on watches for the server, by path."
      .self$send_cmd("wchp") %>% stri_trim() %>% discard(`==`, "") -> res
      data.frame(
        path=qq[seq(1, length(qq), 2)],
        address=qq[seq(2, length(qq), 2)],
        stringsAsFactors=FALSE
      )
    },

    mntr=function() {
      res <- .self$send_cmd("mntr")
      res <- stringi::stri_split_fixed(res, "\t", 2, simplify=TRUE)
      as.list(setNames(res[,2], res[,1]))
    },

    cons=function() {
      "List full connection/session details for all clients connected to this server."
      list(clients=stri_trim(.self$send_cmd("cons") %>%
                               discard(`==`, "")))
    },

    crst=function() {
      "Reset connection/session statistics for all conn"
      message(.self$send_cmd("crst"))
      invisible()
    },

    srst=function() {
      "Reset server statistics."
      message(.self$send_cmd("srst"))
      invisible()
    },

    dump=function() {
      "Lists the outstanding sessions and ephemeral nodes. This only works on the leader."
      res <- paste0(.self$send_cmd("dump"), collapse="\n")
      message(res)
      invisible(res)
    },

    ruok=function() {
      "Tests if server is running in a non-error state. The server will respond with imok if it is running. Otherwise it will not respond at all."
      .self$send_cmd("ruok") == "imok"
    },

    dirs=function() {
      "Shows the total size of snapshot and log files in bytes"
      .self$send_cmd("dirs")
    },

    isro=function() {
      "Tests if server is running in read-only mode."
      .self$send_cmd("isro") == "ro"
    },

    gtmk=function() {
      "Gets the current trace mask as a 64-bit signed long value in decimal format."
      R.utils::intToBin(as.integer(.self$send_cmd("gtmk")))
    },

    send_cmd=function(cmd) {

      "Issue a four-letter command. Used internally but can also be used to take advantage of new commands before a package update."

      sock <- purrr::safely(socketConnection)
      con <- sock(host=.self$host, port=.self$port, blocking=TRUE, open="r+", timeout=.self$timeout)

      if (!is.null(con$result)) {
        con <- con$result
        cat(cmd, file=con)
        response <- readLines(con, warn=FALSE)
        a <- try(close(con))
        purrr::flatten_chr(stringi::stri_split_lines(response))
      } else {
        warning(sprintf("Error connecting to [%s:%s]", host, port))
      }

    }

  )

)