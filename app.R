options(repos = c(CRAN = "https://cloud.r-project.org"))
library(shiny)
library(shinyjs)
library(shinyalert)

install.packages("rsconnect")
library(rsconnect)


ui <- fluidPage(
  useShinyjs(),
  useShinyalert(),
  
  tags$head(
    tags$link(href = "https://fonts.googleapis.com/css2?family=Quicksand&display=swap", rel = "stylesheet"),
    tags$script(src = "https://html2canvas.hertzen.com/dist/html2canvas.min.js"),
    tags$script(HTML("
  function downloadQuoteCard() {
    var element = document.getElementById('quoteCard');
    if (!element) return;
    
    html2canvas(element).then(function(canvas) {
      var link = document.createElement('a');
      link.download = 'MindBloom_QuoteCard.png';
      link.href = canvas.toDataURL();
      link.click(); });
  }

  function createFallingLeaves() {
    const existingLeaves = document.querySelectorAll('.falling-leaf');
    existingLeaves.forEach(leaf => leaf.remove());

    const container = document.body;
    const leafSrc = 'leaf.png'; // make sure this file is in www folder

    for (let i = 0; i < 20; i++) {
      const leaf = document.createElement('img');
      leaf.src = leafSrc;
      leaf.className = 'falling-leaf';
      leaf.style.left = Math.random() * 100 + 'vw';
      leaf.style.animationDelay = Math.random() * 5 + 's';
      container.appendChild(leaf);
    }
  }

  function createFallingFlowers() {
    const existingFlowers = document.querySelectorAll('.falling-flower');
    existingFlowers.forEach(flower => flower.remove());

    const container = document.body;
    const flowerSrc = 'flower.png';

    for (let i = 0; i < 15; i++) {
      const flower = document.createElement('img');
      flower.src = flowerSrc;
      flower.className = 'falling-flower';
      flower.style.left = Math.random() * 100 + 'vw';
      flower.style.animationDelay = Math.random() * 5 + 's';
      container.appendChild(flower);
    }
  }


")),
    tags$style(HTML("
      html, body {
        height: 100%;
        margin: 0;
        padding: 0;
        font-family: 'Quicksand', sans-serif;
        color: #333;
      }
      body.welcome-bg { background-color: #DCEEFB !important; }
      body.mood-bg { background-color: #FFE4F2 !important; }
      body.reflect-bg { background-color: #E0F2FF !important; }
      body.goodbye-bg { background-color: #FFE4F2 !important; }
      .petal-btn {
        background-color: #D6C9F2;
        border: none;
        border-radius: 14px;
        padding: 10px 18px;
        margin: 6px;
        font-size: 16px;
        color: white;
        font-weight: bold;
      }
      .soft-text {
        font-size: 14px;
        font-style: italic;
        color: #999;
      }
  
      #quoteCard, #moodCard {
        font-size: 18px;
        background-color: #FFFAF0;
        padding: 30px;
        border-radius: 12px;
        border: 2px dashed #E3DFFD;
        color: #444;
        width: 80%;
        margin: 20px auto 0 auto;
        text-align: center;
        animation: fadeIn 1s ease-in-out;
      }
      #moodCard:empty {
        display: none;
      }
      .footer {
        position: fixed;
        bottom: 10px;
        left: 0;
        width: 100%;
        text-align: center;
        font-size: 13px;
        font-style: italic;
        color: #999999;
        z-index: 1000;
      }
      
      #name {
    color: #002147;          /* text color */
    font-size: 14px;
    font-style: italic;
    font-weight: bold;
    border: 2px solid #002147;   /* border color */
    border-radius: 8px;
    padding: 8px;
    background-color: #E0FFFF;  /* optional soft background */
      }

@keyframes sway {
  0%   { transform: translateY(0px) rotate(0deg); }
  50%  { transform: translateY(0px) rotate(-2deg); }
  100% { transform: translateY(0px) rotate(0deg); }
}

.sway-plant {
  animation: sway 3s ease-in-out infinite;
}

.falling-leaf {
    position: fixed;
    top: -50px;
    width: 40px;
    height: auto;
    opacity: 0.8;
    z-index: 999;
    animation: fall 8s linear infinite;
    pointer-events: none;
  }

  @keyframes fall {
    0% { transform: translateY(0px) rotate(0deg); }
    100% { transform: translateY(100vh) rotate(360deg);}
  }


.falling-flower {
  position: fixed;
  top: -60px;
  width: 35px;
  height: auto;
  opacity: 0.85;
  z-index: 999;
  animation: fallFlower 10s linear infinite;
  pointer-events: none;
}

@keyframes fallFlower {
  0% { transform: translateY(0px) rotate(0deg); }
  100% { transform: translateY(100vh) rotate(360deg);}
}

#reflect-image {
  position: fixed;
  bottom: 10px;
  right: 30px;
  width: 200px;
  z-index: 10;
  animation: floatReflect 4s ease-in-out infinite;
}

@keyframes floatReflect {
  0% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
  100% { transform: translateY(0px); }
}

#goodbye-image {
  position: fixed;
  bottom: 0px;
  left: 50%;
  transform: translateX(-50%);
  width: 900px;
  height: 280px;
  obect-fit: contain;
  z-index: 10;
  animation: floatGoodbye 6s ease-in-out infinite;
}

@keyframes floatGoodbye {
  0% { transform: translateX(-50%) translateY(0); }
  50% { transform: translateX(-50%) translateY(-10px); }
  100% { transform: translateX(-50%) translateY(0); }
}

    "))
  ),
  
  uiOutput("mainUI"),
  div(class = "footer", "🌸 Made with love by Tisha 🌸")
)

server <- function(input, output, session) {
  page <- reactiveVal("welcome")
  username <- reactiveVal("Bloom")
  
  observe({
    bgClass <- switch(page(),
                      "welcome" = "welcome-bg",
                      "mood" = "mood-bg",
                      "reflect" = "reflect-bg",
                      "goodbye" = "goodbye-bg")
    runjs("document.body.className = ''")
    runjs(sprintf("document.body.classList.add('%s')", bgClass))
    
    
    runjs("document.querySelectorAll('.falling-leaf, .falling-flower').forEach(el => el.remove());")
    
    
    if (page() == "mood") {
      runjs("createFallingLeaves();")
    } else if (page() == "reflect") {
      runjs("createFallingFlowers();")
    }
    
    
  })
  
  output$mainUI <- renderUI({
    switch(page(),
           "welcome" = div(class = "page",
                           tags$img(src = "plant_corner.png", 
                                    class = "sway-plant",
                                    style = "position: absolute; bottom: 15px; right: 15px; 
                  width: 260px; height: auto; opacity: 0.95; z-index:1;"),
                           div(style = "position: relative; width: 500px; margin: 0 auto;",
                               
                               # Background image
                               tags$img(src = "header.png",
                                        style = "width: 100%; height : 200px; display : block; margin : 0 auto; filter : drop-shadow(0 0 0.75rem #add8e6;"),
                               
                               # Overlay text on top of image
                               div(style = "
         position: absolute;
         top: 40%;
         left: 50%;
         transform: translate(-50%, -50%);
         text-align: center;
         color: #26428B;
         ",
                                   h2("MIND BLOOM", style = "font-size: 28px;font-style: italic; font-weight: bold; margin-bottom: 4px;"),
                                   h4("A gentle 1-minute escape from chaos", style = "font-size: 14px; font-weight: bold; font-style: italic;")
                               )
                           ),
                           h4("Hiiiii 🌸", style = "color: #26428B; font-size: 20px;font-style: italic; font-weight: bold;"),
                           h4("I'm so happy you're here !!", style = "color: #26428B; font-size: 20px;font-style: italic; font-weight: bold;"),
                           h4("Welcome to Mind Bloom — a tiny corner of peace just for you.", style = "color: #26428B; font-size: 20px;font-style: italic; font-weight: bold;"),
                           br(),
                           h4("There's no rush here, No expectations", style = "color: #26428B; font-size: 20px; font-style: italic; font-weight: bold;"),
                  
                           h4("Just calm, just softness", style = "color: #26428B; font-size: 20px; font-style: italic; font-weight: bold;"),
                           br(),
                           textInput("name",
                                     HTML("<span style='color:#002147; font-size:20px; font-weight:bold; font-style:italic;'>Now tell me your lovely name so I can greet you properly 🌷</span>"),
                                     placeholder = "Or skip and be Bloom 🌸"
                           ),
                                      
                           actionButton("go", "Enter" , style = "background-color: #002147; color: white; font-weight: bold; border-radius: 12px; padding: 8px 16px; border: none;")
           ),
           "mood" = div(class = "page",
                        tags$div(
                          style = "position: absolute; bottom: 5px; right: 0; height: 200px; overflow: hidden; z-index: 0;",
                          tags$img(src = "mood.png", style = "height: 100%; object-fit: cover; object-position: right; opacity: 0.9;")
                        ),
                        uiOutput("greeting"),
                        h3("Stay as long or as little as you need . . . .", style = "color:#FF1493; font-weight: bold; font-style: italic;"),
                        br(), br(),
                        h3("Tell me how your heart feels today . . . ", style = "color: #9966CC; font-weight: bold; font-style: italic;"),
                        h3("Pick a petal 🌼 ~ ", style = "color: #9966CC; font-weight: bold; font-style: italic;"),
                        br(),
                        actionButton("happy", "🌞 Happy", class = "petal-btn"),
                        actionButton("okay", "OK-OK", class = "petal-btn"),
                        actionButton("Hopeful", "Hopeful", class = "petal-btn"),
                        actionButton("Lost", "🌪Lost", class = "petal-btn"),
                        actionButton("tired", "😴 Tired", class = "petal-btn"),
                        actionButton("sad", "Sad", class = "petal-btn"),
                        actionButton("Grateful", "Grateful", class = "petal-btn"),
                        div(id = "moodCard", textOutput("reflection")),
                        br(),
                        br(),
                        actionButton("nextReflect", "Next ➡️", style = "background-color: #FFB6C1; color: white; font-weight: bold; border-radius: 12px; padding: 8px 16px; border: none;")
           ),
           "reflect" = div(class = "page",
                           tags$img(src = "reflect_object.png", id = "reflect-image"),
                           br(),
                           textInput("kindNote", 
                                     tags$span("Would you like to leave a kind note to yourself today?", 
                                               style = "color:#333399; font-size: 20px; font-weight:bold; font-style: italic;"),
                                     placeholder = "[ Optional ... Just for you]"),
                           br(),
                           actionButton("reflectBtn", "ENTER 🌸" , style = "background-color: #6495ED; color: white; font-weight: bold; border-radius: 12px; padding: 8px 16px; border: none;"),
                           tags$div(
                             style = "font-size: 13px; color: #333399; font-weight: bold; text-align: left; font-style: italic;",
                             "Please press Enter"),
                           uiOutput("quoteCard"),
                           br(), actionButton("downloadImg", "Download Quote Card as Image 💌", 
                                              onclick = "downloadQuoteCard()",
                                              style = "background-color: #4169E1; color: white; font-weight: bold; border-radius: 10px; padding: 10px 20px; border: none;"),
                           br(), 
                           br(),
                           actionButton("nextGoodbye", "Next ➡️" , style = "background-color: #6495ED; color: white; font-weight: bold; border-radius: 12px; padding: 8px 16px; border: none;")
           ),
           "goodbye" = div(class = "page",
                           tags$img(src = "goodbye_object.png", id = "goodbye-image"),
                           tags$div(
                             style = "font-size: 21px; color: #E75480;font-weight: bold; font-style: italic; text-align: left;",
                            sprintf( " Dear %s ,", username())),
                           tags$div(
                             style = "font-size: 21px; color: #E75480; font-weight: bold; text-align: left; font-style: italic;",
                             "If today was heavy, I hope this helped you carry a little of it 💫"
                           ),
                           uiOutput("goodbyeQuote"), 
                           br(), 
                          
                           tags$div(
                             style = "font-size: 21px; color: #E75480;font-weight: bold; font-style: italic; text-align: left;",
                             "That's all for today, beautiful soul 💖 "),
                           tags$div(
                             style = "font-size: 21px; color: #E75480; font-weight: bold; font-style: italic; text-align: left;",
                             "Go on . . . Carry this calm with you "),
                          br(),
                           actionButton("exitBtn", "Return to World 🌍", style = "color: white; background-color: #FF69B4; padding: 10px 20px; border-radius: 10px; font-weight: bold;"),
                          tags$div(
                            style = "font-size: 13px; color: #999; text-align: left;",
                            "i.e. Back to reality.."),
                           br(),
                           tags$div(
                             style = "font-size: 17px; color: #999; text-align: left; font-style: italic;",
                             " Thank you for pausing here with me today . . . ."),
                           tags$div(
                             style = "font-size: 17px; color: #999; text-align: left; font-style: italic;",
                             "If this space gave your heart a breath, then it did what it was meant to do."
                           ),
                          tags$div(
                            style = "font-size: 17px; color: #999; text-align: left; font-style: italic;",
                            "Bye Bye"
                          ),
                          tags$div(
                            style = "font-size: 17px; color: #999; text-align: left; font-style: italic;",
                            "~ Tisha 🌸 "
                          )
           )
    )
  })
  
  observeEvent(input$go, {
    name <- ifelse(input$name == "", "Bloom", input$name)
    username(name)
    greetings <- c(
      "Hiii %s 💗 It's time to breathe and pause for a while",
      "Hii %s, This is your moment. Let's slow down together.",
      "Hey %s ! You've carried so much. Let's set it down for a while"
    )
    
    output$greeting <- renderUI({
      tags$div(
        style = "font-size: 24px; font-weight: bold; font-style: italic; color: #FF1493; margin-top: 15px;",
        sprintf(sample(greetings, 1), name)
      )
    })
    
    shinyalert(
      title = sprintf("🌸 Hi %s 🌸", name),
      text = HTML("WELCOME HOME ❤
                  This soft corner was waiting for you !! "),
      type = "",
      showConfirmButton = TRUE,
      confirmButtonText = "Awww thank you",
      confirmButtonCol = "#FDC5F5"
    )
    page("mood")
  })
  
  observeEvent(input$happy, { output$reflection <- renderText("That happiness looks good on you...I hope life keeps giving you more reasons to smile like this !!") })
  observeEvent(input$okay, { output$reflection <- renderText("Hey! Some days dont sing, they hum quietly. . . And even that hum means your heart's still moving forward. . .You don't have to bloom everyday, Love . . .") })
  observeEvent(input$Hopeful, { output$reflection <- renderText("Hope is a proof that you're still reaching towards the light. Keep going  . . .💗") })
  observeEvent(input$Lost, { output$reflection <- renderText("Breathe in. Breathe out️... Even stars get lost behind clouds - but they're still there. Feeling lost is how we start finding ourselves . . .") })
  observeEvent(input$tired, { output$reflection <- renderText("Heyy It's okay to slow down. Life's not a race. Rest now, sweetheart. The world can wait. . .") })
  observeEvent(input$sad, { output$reflection <- renderText("Even the sky gets heavy . . . but clouds always pass. It will be all right, love. ") })
  observeEvent(input$Grateful, { output$reflection <- renderText("To feel grateful is to notice life loving you back and there's something magical about a grateful soul like you ...🌈") })
  
  observeEvent(input$nextReflect, { page("reflect") })
  
  observeEvent(input$reflectBtn, {
    if (input$kindNote == "") {
      output$quoteCard <- renderUI({
        div(id = "quoteCard", "🌸 You didn't leave a note, but your silence is still soft and beautiful 💖")
      })
    } else {
      output$quoteCard <- renderUI({
        div(id = "quoteCard", paste0("💖 You said: ‘", input$kindNote, "’. That’s beautiful. Remember what you said !!"))
      })
    }
  })
  
  output$downloadCard <- downloadHandler(
    filename = function() { "MindBloom_Note.txt" },
    content = function(file) {
      writeLines(paste("💖 You said: '", input$kindNote, "'. That's beautiful."), file)
    }
  )
  
  observeEvent(input$nextGoodbye, { page("goodbye") })
  
  
  observeEvent(input$exitBtn, {
    session$reload()
  })
}

shinyApp(ui, server)
