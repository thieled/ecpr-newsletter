quarto::quarto_render("template/newsletter_template_v3.qmd")

html <- readr::read_file("template/newsletter_template_v3.html")
html <- juicyjuice::css_inline(html)
readr::write_file(html, "template/newsletter_template_v3.html")

