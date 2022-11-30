library(tidyverse)
library(parallel)

# you may need to set working directory
#setwd()

# read in the data
df <- read_csv("../../data_frames/targeted_with_imps.csv") %>% 
  filter(is_standard == FALSE)

# these are the mutator lines
mut.lines <- c("A-1", "A-2", "A-3", "A-4", "A+3", "A+6")

# these are the clean names for the lines
clean.names <- data.frame(line = unique(df$line)) %>%
  mutate(clean = case_when(
    grepl("ap", line) ~ str_replace(line, "ap", "A+"),
    grepl("am", line) ~ str_replace(line, "am", "A-"),
    grepl("rel", line) ~ str_replace(line, "rel60", "R0")
  ))

# add the clean names to the df
df <- left_join(df, clean.names) %>% 
  mutate(is_mutator = clean %in% mut.lines,
         phase = ifelse(phase == "e", "Ex", "St"))

# these are the ancestral mean peak areas
anc.vals <- df %>% 
  mutate(age = ifelse(grepl("R0", clean), "Ancestor", "Evolved")) %>% 
  filter(age == "Ancestor") %>% 
  group_by(charge, phase, compound) %>% 
  summarise(anc_mean = mean(n_peak_area)) %>% 
  ungroup()

# these are the evo mean peak areas
evo.vals <- df %>% 
  mutate(age = ifelse(grepl("R0", clean), "Ancestor", "Evolved")) %>% 
  filter(age != "Ancestor") %>% 
  group_by(charge, phase, compound, clean) %>% 
  summarise(evo_mean = mean(n_peak_area)) %>% 
  ungroup()

# combine them and calculate fold changes
fc.df <- left_join(evo.vals, anc.vals) %>% 
  mutate(l2ratio = log2(evo_mean / anc_mean)) %>% 
  select(charge, phase, compound, clean, l2ratio)

# calculate actual correlations
fc.cors <- fc.df %>%
  split(.$phase) %>%
  map(function(x) {
    cor.input <- x %>%
      select(-phase) %>%
      unite("comp", charge, compound, sep = "_") %>%
      pivot_wider(names_from = clean, values_from = l2ratio) %>%
      column_to_rownames("comp")
    
    cor.res <- cor(cor.input)
    
    # remove redundancy
    cor.res[lower.tri(cor.res)] <- NA
    
    # reshape to a tidy data frame with complete info on line, phase, repl, etc
    cor.df <- as_tibble(cor.res, rownames = "samp1") %>%
      pivot_longer(where(is.numeric),
                   names_to = "samp2",
                   values_to = "R") %>%
      filter(samp1 != samp2 & !is.na(R))
  }) %>% 
  bind_rows(.id = "phase") %>% 
  mutate(iter = "Observed",
         points = R)

# calculate cors after randomizations
rand.cors <- mclapply(1:1e5, function(x) {
  fc.df %>%
    split(.$phase) %>%
    map(function(y) {
      cor.input <- y %>%
        select(-phase) %>%
        unite("comp", charge, compound, sep = "_") %>%
        pivot_wider(names_from = clean, values_from = l2ratio) %>%
        column_to_rownames("comp")
      
      # randomize the fold changes
      cor.input <- apply(cor.input, 2, function(y) {
        sample(y, size = length(y), replace = FALSE)
      })
      
      cor.res <- cor(cor.input)
      
      # remove redundancy
      cor.res[lower.tri(cor.res)] <- NA
      
      # reshape to a tidy data frame with complete info on line, phase, repl, etc
      cor.df <- as_tibble(cor.res, rownames = "samp1") %>%
        pivot_longer(where(is.numeric),
                     names_to = "samp2",
                     values_to = "R") %>%
        filter(samp1 != samp2 & !is.na(R))
    }) %>% 
    bind_rows(.id = "phase") %>%
    mutate(iter = "Expected",
           points = NA)
}, mc.cores = 16) %>% 
  bind_rows()

combo.cors <- bind_rows(
  fc.cors, 
  rand.cors
)

write_csv(combo.cors, "../../data_frames/randomizations_for_fig2.csv.gz")