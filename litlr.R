# Copyright (C) 2013 Gray Calhoun

# This file is part of the LitLR package. LitLR is free software; you
# can redistribute it and/or modify it under the terms of the GNU
# General Public License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option) any later
# version.

# LitLR is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.

# You should have received a copy of the GNU General Public License
# along with LitLR; if not, see <http://www.gnu.org/licenses/>.

require(knitr)
require(tools)

args <- commandArgs(trailingOnly = TRUE)
infile <- args[1]

stopifnot(file_ext(infile) == "tex")
outfile <- gsub(".tex", ".R", infile)
macfile <- gsub(".tex", ".llr", infile)

cschar <- "sprintf(\"\\\\expandafter\\\\def\\\\csname %s@%s\\\\endcsname{%%s}\\n\", %s)"

knit_patterns$set(list('chunk.begin' = '\\\\begin\\{lstlisting\\}.*',
                       'chunk.end'='\\\\end\\{lstlisting\\}'))

lit <- function(infile, re = "\\\\Rcall\\{(.+?)\\}", TeXarray = "rcall") {
  connection <- file(infile)
  textlines <- readLines(connection)
  close(connection)
  
  Rcalls <- gsub(re, "\\1", unlist(regmatches(textlines, gregexpr(re, textlines))))
  Rcalls <- unique(Rcalls)
  sprintf(cschar, TeXarray, Rcalls, Rcalls)
}

purl(infile, output = outfile)
cat(file = outfile, append = TRUE,
    sprintf("cat(file = \"%s\",\n", macfile),
    paste(lit(infile), collapse = ",\n"), ")")
