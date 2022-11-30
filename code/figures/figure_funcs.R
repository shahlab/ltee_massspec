# figure functions 

### figure s2
dotplot_graph <- function(x,n) {
  # get the comps and clean it up
  comp.df <- df %>% 
    filter(compound %in% x) %>% 
    mutate(charge = ifelse(charge == "positive", "(+)", "(-)"),
           phase = ifelse(phase == "e", "Exponential", "Stationary"))
  
  # get evo values
  evo.pa <- comp.df %>%
    filter(!grepl("R0", clean)) %>%
    group_by(clean, phase, compound, charge) %>%
    summarise(evompa = mean(n_peak_area)) %>%
    ungroup()
  
  # get ancestral values
  anc.pa <- comp.df %>%
    filter(grepl("R0", clean)) %>%
    group_by(phase, compound, charge) %>%
    summarise(ancmpa = mean(n_peak_area)) %>%
    ungroup()
  
  # combine and calc changes
  fc.df <-
    left_join(evo.pa, anc.pa, by = c("phase", "compound", "charge")) %>%
    mutate(l2rat = log2(evompa / ancmpa),
           compound = factor(compound, rev(x)))
  
  # plot it
  p <- fc.df %>%
    ggplot(., aes(l2rat, compound, color = charge)) +
    geom_vline(aes(xintercept = 0), linetype = 5)+
    geom_point(position = position_dodge(width = .9), alpha = .25) +
    facet_wrap( ~ phase, ncol = n) +
    theme_bw() +
    theme(
      text = element_text(size = 12),
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank()
    ) +
    labs(x = expression(paste(log[2], "(Evo peak area / Anc peak area)")),
         y = NULL)+
    scale_color_manual(values = c("black", "red"), guide = "none")
  
  return(p)
}

# different version of the above function that orders the compounds by their
# median values rather than the alphabetical, it's ordering by the median of all
# the values, not just one ionization mode because not all compounds are present
# in all ionization modes and you don't really know which one is "correct"
dotplot_med_graph <- function(x) {
  # get the comps and clean it up
  comp.df <- df %>% 
    filter(compound %in% x) %>% 
    mutate(charge = ifelse(charge == "positive", "(+)", "(-)"),
           phase = ifelse(phase == "e", "Exponential", "Stationary"))
  
  # get evo values
  evo.pa <- comp.df %>%
    filter(!grepl("R0", clean)) %>%
    group_by(clean, phase, compound, charge) %>%
    summarise(evompa = mean(n_peak_area)) %>%
    ungroup()
  
  # get ancestral values
  anc.pa <- comp.df %>%
    filter(grepl("R0", clean)) %>%
    group_by(phase, compound, charge) %>%
    summarise(ancmpa = mean(n_peak_area)) %>%
    ungroup()
  
  # combine and calc changes
  fc.df <-
    left_join(evo.pa, anc.pa, by = c("phase", "compound", "charge")) %>%
    mutate(l2rat = log2(evompa / ancmpa),
           compound = factor(compound, rev(x)))
  
  # get median order for ex phase
  med.order <- fc.df %>%
    filter(phase == "Exponential") %>% 
    group_by(compound) %>% 
    summarise(med = median(l2rat)) %>% 
    ungroup() %>% 
    arrange(med) %>% 
    pull(compound)
  
  fc.df$compound <- factor(fc.df$compound, levels = med.order)
    
  # plot it
  p <- fc.df %>%
    ggplot(., aes(l2rat, compound, color = charge)) +
    geom_vline(aes(xintercept = 0), linetype = 5)+
    geom_point(position = position_dodge(width = .9), alpha = .25) +
    facet_wrap( ~ phase) +
    theme_bw() +
    theme(
      text = element_text(size = 12),
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank()
    ) +
    labs(x = expression(paste(log[2], "(Evo peak area / Anc peak area)")),
         y = NULL)+
    scale_color_manual(values = c("black", "red"), guide = "none")
  
  return(p)
}

range_func <- function(x) {
  comp.df <- df %>%
    filter(compound %in% x) %>%
    mutate(phase = ifelse(phase == "e", "Exponential", "Stationary")) %>%
    select(-line)
  
  evo.pa <- comp.df %>%
    filter(!grepl("R0", clean)) %>%
    group_by(clean, phase, charge, compound) %>%
    summarise(evompa = mean(n_peak_area)) %>%
    ungroup()
  
  anc.pa <- comp.df %>%
    filter(grepl("R0", clean)) %>%
    group_by(phase, charge, compound) %>%
    summarise(ancmpa = mean(n_peak_area)) %>%
    ungroup()
  
  fc.df <-
    left_join(evo.pa, anc.pa, by = c("phase", "charge", "compound")) %>%
    mutate(
      l2rat = log2(evompa / ancmpa),
      mutator = clean %in% mut.lines,
      compound = factor(compound, levels = rev(x))
    ) %>% 
    split(list(.$compound, .$phase)) %>% 
    map(function(y){
      enframe(range(y$l2rat)) %>% 
        mutate(name = ifelse(name == 1, "min", "max"),
               mean_change= mean(y$l2rat),
               median_change = median(y$l2rat))
    }) %>% 
    bind_rows(.id = "cc") %>% 
    separate(cc, into = c("compound", "phase"), sep = "\\.") %>% 
    pivot_wider(names_from = name, values_from = value) %>% 
    mutate(across(where(is.numeric), ~ signif(2^.x, 3)))
  
  # how many up/down in each compound
  cdf <- left_join(evo.pa, anc.pa, by = c("phase", "charge", "compound")) %>%
    mutate(
      l2rat = log2(evompa / ancmpa),
      mutator = clean %in% mut.lines,
      compound = factor(compound, levels = rev(x))
    ) %>% 
    mutate(direc = ifelse(l2rat > 0, "up", "down")) %>% 
    group_by(compound, charge, direc, phase) %>% 
    tally() %>% 
    ungroup() %>% 
    pivot_wider(names_from = c(charge, direc), values_from = n)
  
  fdf <- left_join(fc.df, cdf, by = c("phase", "compound"))
  
  return(fdf)
}

# line breaker, A function that inserts a line break if the names too long
# the input is the max number of characters on a line
line_breaker <- function(x){
  if (nchar(x) > 30){
    tmp <- paste0(
      str_sub(x, start = 1, end = nchar(x)/2),
      "-\n",
      str_sub(x, start = (nchar(x)/2)+1, end = -1)
    )
  } else {
    tmp <- x
  }
  
  return(tmp)
}