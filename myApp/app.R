library(shiny)
library(plotly)
library(shinycssloaders)
df = read.csv("data/dailyDataAQI.csv")
df$Date = as.Date(df$Date)

df24 = read.csv("https://raw.githubusercontent.com/waitasecant/Air-Pollution-Dashboard/main/myApp/data/realTimeDelhi.csv")
df24$Date =as.POSIXct(df24$Date, format = "%Y-%m-%d %H:%M:%S")

aqitab = c("0-50", "51-100", "101-200", "201-300", "301-400", "401+")
pm25tab = c("0-30", "31-60", "61-90", "91-120", "121-250", "250+")
pm10tab = c("0-50", "51-100", "101-250", "251-350", "351-430", "430+")
nh3tab = c("0-200", "201-400", "401-800", "801-1200", "1200-1800", "1800+")
so2tab = c("0-40", "41-80", "81-380", "381-800", "801-1600", "1600+")
categorytab = c("Good", "Satisfactory", "Moderate", "Poor", "Very Poor", "Severe")

naaqstab24 = data.frame(list("Category"=categorytab,  "AQI"=aqitab, "PM2.5"=pm25tab, "PM10"=pm10tab, "NH3" = nh3tab, "SO2" = so2tab), check.names = FALSE)
naaqstab = data.frame(list("Category"=categorytab, "AQI"=aqitab,"PM2.5"=pm25tab, "PM10"=pm10tab, "NH3" = nh3tab, "SO2" = so2tab), check.names = FALSE)

col = list("darkredp"=rgb(0.78, 0.063, 0.063), "redp"=rgb(1, 0.165, 0), "orangep"=rgb(1, 0.702, 0),
           "yellowp"=rgb(1, 0.918, 0.118), "greenp"=rgb(0.349,0.8,0.133), "darkgreenp"=rgb(0.204, 0.639, 0))

fillcol = list("darkredp"=rgb(0.78, 0.063, 0.063,0.5), "redp"=rgb(1, 0.165, 0,0.5), "orangep"=rgb(1, 0.702, 0,0.5),
               "yellowp"=rgb(1, 0.918, 0.118,0.5), "greenp"=rgb(0.349,0.8,0.133,0.5), "darkgreenp"=rgb(0.204, 0.639, 0,0.5))
# -------------Helper Functions-------------------------------------------------

getMonths = function(y){
    if (y==2022){
        return(c("January", "February", "March", "April", "May", "June", "July", "August",
                 "September", "October", "November", "December"))
    }
    else{
        return(c("January", "February", "March", "April", "May", "June", "July", "August",
                 "September", "October"))}
}


getFileName = function(y,m){
    return(paste(as.character(y),m,".jpg", sep=""))
}


getDelhiSites = function(df){
    return(unique(df[df$State=="Delhi",]$Site))
}


getRangeDataTS = function(df, par, start, end, site){
    df = df[df$Date<=end,]
    df = df[df$Date>=start,]
    df = subset(df,Site==site, select=c("Date", par))
    return(getPartitions(df, par))
}


getRangeDataTS24 = function(df, par, site){
    df = subset(df,Site==site,select=c("Date", par))
    df = df[df[,par]!=-1,]
    return(getPartitions(df, par))
}

getRangeDataTS24Pt = function(df, par, site){
    df = subset(df,Site==site,select=c("Date", par))
    df = df[df[,par]!=-1,]
    return(list("Date" = df$Date, "par" = df[,par]))
}


getPartitions = function(df, par){
    y0 = df[,par]
    if (length(y0)>0){
        y0 = y0[1:(length(y0)-1)]
        
        if (par=="AQI"){
            colourCode = ifelse(y0>401, "darkred", ifelse(301<y0, "red", ifelse(201<y0, "orange",
                                                                                ifelse(61<y0, "yellow2", ifelse(31<y0, "green3", "darkgreen")))))
        }
        if (par=="PM2.5"){
            colourCode = ifelse(y0>250, "darkred", ifelse(121<y0, "red", ifelse(91<y0, "orange",
                                                                                ifelse(61<y0, "yellow2", ifelse(31<y0, "green3", "darkgreen")))))
        }       
        if (par=="PM10"){
            colourCode = ifelse(y0>430, "darkred", ifelse(351<y0, "red", ifelse(251<y0, "orange",
                                                                                ifelse(101<y0, "yellow2", ifelse(51<y0, "green3", "darkgreen")))))
        }
        if (par=="NH3"){
            colourCode = ifelse(y0>1800, "darkred", ifelse(1200<y0, "red", ifelse(801<y0, "orange",
                                                                                ifelse(401<y0, "yellow2", ifelse(201<y0, "green3", "darkgreen")))))
        }
        if (par=="SO2"){
            colourCode = ifelse(y0>1600, "darkred", ifelse(801<y0, "red", ifelse(381<y0, "orange",
                                                                                ifelse(81<y0, "yellow2", ifelse(41<y0, "green3", "darkgreen")))))
        }
        
        darkredx0 = c()
        darkredx1 = c()
        darkredy0 = c()
        darkredy1 = c()
        
        redx0 = c()
        redx1 = c()
        redy0 = c()
        redy1 = c()
        
        orangex0 = c()
        orangex1 = c()
        orangey0 = c()
        orangey1 = c()
        
        yellowx0 = c()
        yellowx1 = c()
        yellowy0 = c()
        yellowy1 = c()
        
        greenx0 = c()
        greenx1 = c()
        greeny0 = c()
        greeny1 = c()
        
        darkgreenx0 = c()
        darkgreenx1 = c()
        darkgreeny0 = c()
        darkgreeny1 = c()
        
        for (i in 1:length(colourCode)){
            if (colourCode[i]=="darkred"){
                darkredx0 = append(darkredx0,df$Date[i])
                darkredx1 = append(darkredx1,df$Date[i+1])
                darkredy0 = append(darkredy0,df[,par][i])
                darkredy1 = append(darkredy1,df[,par][i+1])
            }
            else if (colourCode[i]=="red"){
                redx0 = append(redx0,df$Date[i])
                redx1 = append(redx1,df$Date[i+1])
                redy0 = append(redy0,df[,par][i])
                redy1 = append(redy1,df[,par][i+1])
            }
            else if (colourCode[i]=="orange"){
                orangex0 = append(orangex0,df$Date[i])
                orangex1 = append(orangex1,df$Date[i+1])
                orangey0 = append(orangey0,df[,par][i])
                orangey1 = append(orangey1,df[,par][i+1])
            }
            else if (colourCode[i]=="yellow2"){
                yellowx0 = append(yellowx0,df$Date[i])
                yellowx1 = append(yellowx1,df$Date[i+1])
                yellowy0 = append(yellowy0,df[,par][i])
                yellowy1 = append(yellowy1,df[,par][i+1])
            }
            else if (colourCode[i]=="green3"){
                greenx0 = append(greenx0,df$Date[i])
                greenx1 = append(greenx1,df$Date[i+1])
                greeny0 = append(greeny0,df[,par][i])
                greeny1 = append(greeny1,df[,par][i+1])
            }
            else if (colourCode[i]=="darkgreen"){
                darkgreenx0 = append(darkgreenx0,df$Date[i])
                darkgreenx1 = append(darkgreenx1,df$Date[i+1])
                darkgreeny0 = append(darkgreeny0,df[,par][i])
                darkgreeny1 = append(darkgreeny1,df[,par][i+1])
            }
        }
        
        darkredPartitions = list("x" = darkredx0, "xend"= darkredx1, "y"= darkredy0, "yend"= darkredy1)
        redPartitions = list("x" = redx0, "xend"= redx1, "y"= redy0, "yend"= redy1)
        orangePartitions = list("x" = orangex0, "xend"= orangex1, "y"= orangey0, "yend"= orangey1)
        yellowPartitions = list("x" = yellowx0, "xend"= yellowx1, "y"= yellowy0, "yend"= yellowy1)
        greenPartitions = list("x" = greenx0, "xend"= greenx1, "y"= greeny0, "yend"= greeny1)
        darkgreenPartitions = list("x" = darkgreenx0, "xend"= darkgreenx1, "y"= darkgreeny0, "yend"= darkgreeny1)
        partitions = list("darkredp" = darkredPartitions, "redp" = redPartitions,"orangep" = orangePartitions,
                        "yellowp" = yellowPartitions,"greenp" = greenPartitions,"darkgreenp" = darkgreenPartitions)
        return(partitions)
    }
    else{
        return(0)
    }
}


hoverName = function(par, col){
    if (par=="AQI"){
        if(col=="darkredp"){
            return(paste(isolate(par),">401", sep=""))
        }
        if(col=="redp"){
            return(paste("301<",isolate(par),"<400", sep=""))
        }
        if(col=="orangep"){
            return(paste("201<",isolate(par),"<300", sep=""))
        }
        if(col=="yellowp"){
            return(paste("101<",isolate(par),"<200", sep=""))
        }
        if(col=="greenp"){
            return(paste("51<",isolate(par),"<100", sep=""))
        }
        if(col=="darkgreenp"){
            return(paste(isolate(par),"<51", sep=""))
        }
    }
    if (par=="PM2.5"){
        if(col=="darkredp"){
            return(paste(isolate(par),">250", sep=""))
        }
        if(col=="redp"){
            return(paste("121<",isolate(par),"<250", sep=""))
        }
        if(col=="orangep"){
            return(paste("91<",isolate(par),"<121", sep=""))
        }
        if(col=="yellowp"){
            return(paste("61<",isolate(par),"<91", sep=""))
        }
        if(col=="greenp"){
            return(paste("31<",isolate(par),"<61", sep=""))
        }
        if(col=="darkgreenp"){
            return(paste(isolate(par),"<31", sep=""))
        }
    }
    if (par=="PM10"){
        if(col=="darkredp"){
            return(paste(isolate(par),">430", sep=""))
        }
        if(col=="redp"){
            return(paste("351<",isolate(par),"<430", sep=""))
        }
        if(col=="orangep"){
            return(paste("251<",isolate(par),"<351", sep=""))
        }
        if(col=="yellowp"){
            return(paste("101<",isolate(par),"<251", sep=""))
        }
        if(col=="greenp"){
            return(paste("51<",isolate(par),"<101", sep=""))
        }
        if(col=="darkgreenp"){
            return(paste(isolate(par),"<51", sep=""))
        }
    }
    if (par=="NH3"){
        if(col=="darkredp"){
            return(paste(isolate(par),">1800", sep=""))
        }
        if(col=="redp"){
            return(paste("1200<",isolate(par),"<1800", sep=""))
        }
        if(col=="orangep"){
            return(paste("801<",isolate(par),"<1200", sep=""))
        }
        if(col=="yellowp"){
            return(paste("401<",isolate(par),"<801", sep=""))
        }
        if(col=="greenp"){
            return(paste("201<",isolate(par),"<401", sep=""))
        }
        if(col=="darkgreenp"){
            return(paste(isolate(par),"<201", sep=""))
        }
    }
    if (par=="SO2"){
        if(col=="darkredp"){
            return(paste(isolate(par),">1600", sep=""))
        }
        if(col=="redp"){
            return(paste("801<",isolate(par),"<1600", sep=""))
        }
        if(col=="orangep"){
            return(paste("381<",isolate(par),"<801", sep=""))
        }
        if(col=="yellowp"){
            return(paste("81<",isolate(par),"<381", sep=""))
        }
        if(col=="greenp"){
            return(paste("41<",isolate(par),"<81", sep=""))
        }
        if(col=="darkgreenp"){
            return(paste(isolate(par),"<41", sep=""))
        }
    }
    
}

# -------------UI Starts--------------------------------------------------------

ui = fluidPage(
    tags$head(includeHTML("google-analytics.html")),
    withMathJax(),
    theme = shinythemes::shinytheme("flatly"),
    tags$head(tags$style(HTML('* {font-family: "Bell MT"};'))),
    tags$style(type = 'text/css', '.navbar-nav li a {font-size: 14pt;}'),
    navbarPage("",
               # -------------Home Page------------------------------------------------------
               tabPanel("Home",
                        titlePanel(strong(p("Welcome to the Delhi Air Pollution Dashboard", align="center", style = "font-size:28pt"))),
                        fluidRow(br()),
                        fluidRow(div(style = "width: 95%; margin: auto; font-size:14pt; text-align:justify",
                                     p("This is an interactive dashboard made as part of the Project Component-2 for the Visualization Class taken by Dr. Sourish Das in the first semester at CMI. The data consists of four air pollution parameters i.e. PM2.5, PM10, NH3, SO2 for 25 stations in Delhi, 10 stations in UP and 7 stations in Haryana, collected from", a(href='https://app.cpcbccr.com/ccr/#/caaqm-dashboard-all/caaqm-landing','CPCB website'), "from January 1, 2022 to October 31, 2023 on daily basis. The data for the parameters is average of 24 hour data collected every 15 minutes. The units for all the parameters in the data are micrograms of a gaseous pollutant per cubic meter of air (\\(\\mu g/m^{3}\\)). The AQI was calculated using an AQI calculator from CPCB website available", a(href='https://app.cpcbccr.com/ccr_docs/AQI%20-Calculator.xls','here'),"using python module xlwings."),
                                     p("The choropleth maps are prepared by using the data from 17 stations in Haryana and Uttar Pradesh surrounding Delhi and 25 stations inside Delhi. The monthly average data was interpolated using Inverse Distance Weighted Interpolation in 10km\\(\\times\\)10km grids. The location of the stations were obtained from", a(href='https://app.cpcbccr.com/ccr/#/caaqm-dashboard-all/caaqm-landing', 'CPCB website'),". Two maps are displayed, first on a constant scale across months, other on that month specific scale, for better interpretation. The time-series plots are colour-coded in accordance with", a(href='https://cpcb.nic.in/air-quality-standard/', 'NAAQS'),". Last 24-hour data is being scrapped every 15 minutes from", a(href='https://www.dpccairdata.com/dpccairdata/display/', 'DPCC website'), "using Github Actions."),
                                     p("Click on the Dashboard tab. Happy Voyage!"),
                                     p("Contact me at", a(href='mailto:waitasecant@gmail.com','waitasecant@gmail.com'))
                        )),
                        fluidRow(div(style = "width: 95%; margin: auto; font-size:10pt; text-align:justify",
                                     p("*The image below is just a representation of what went behind creating these maps!"))),
                        fluidRow(
                            column(3,offset=0.5,imageOutput("stations_ncr")),
                            column(3,offset=0.5,imageOutput("grid_ncr")),
                            column(3,offset=0.5,imageOutput("plot_ncr")),
                            column(3,offset=0.5,imageOutput("plot_delhi"))
                        )
               ),
               # -------------Dashboard Page ------------------------------------------------
               navbarMenu("Dashboard",
                          tabPanel("Choropleth Maps",
                                   fluidRow(column(4),strong(p("Choropleth map of monthly average of pollutant parameter",
                                                                          align="center",style = "font-size:18pt"))),
                                   
                                   fluidRow(column(4, offset= 0.5,
                                                   selectInput("yearMap", "Year", c(2023, 2022), width="400pt"),
                                                   selectInput("monthMap", "Month", choices = NULL, width="400pt"),
                                                   selectInput("paramMap", "Pollutant", c("AQI","PM2.5", "PM10", "NH3", "SO2"), width="400pt"),
                                                   actionButton("plotbuttonCM", "PLOT",class = "btn-sm btn-primary", width="400pt")
                                   ),
                                   column(4,imageOutput("monthlyAvgGlobal")|>withSpinner(color="black"),br(),br(),hr(),
                                          p("Monthly average on fixed scale of values observed.",align="center",style = "font-size:12pt")),
                                   column(4,imageOutput("monthlyAvgLocal")|>withSpinner(color="black"),br(),br(),hr(),
                                          p("Monthly average on scale for the selected month.",align="center",style = "font-size:12pt"))
                                   )
                          ),
                          tabPanel("Time-Series Plots",
                                   fluidRow(column(4),strong(p("Time-series plot of daily average of pollutant parameter",
                                                                          align="center",style = "font-size:18pt"))),
                                   fluidRow(column(4,
                                                   selectInput("siteTS", "Station", getDelhiSites(df), width="400pt"),
                                                   selectInput("paramTS", "Pollutant", c("AQI","PM2.5", "PM10", "NH3", "SO2"), width="400pt"),
                                                   dateRangeInput("daterangeTS", "Date Range", start = max(df$Date)-30, end = max(df$Date),
                                                                  min = "2022-01-01", max = "2023-10-31", format="dd-mm-yyyy", width="400pt"),
                                                   checkboxInput("checkTS", "Fill the area under the curve", value = FALSE),
                                                   actionButton("plotbuttonTS", "PLOT",class = "btn-sm btn-primary", width="400pt"),
                                                   br(),br(),br(),
                                                   div(style = "margin: auto; font-size:12pt; text-align:left",
                                                       strong(p("National Ambient Air Quality Standard (\\(\\mu g/m^{3}\\))"))),
                                                   tableOutput("naaqstable")
                                   ),
                                   column(8, plotlyOutput("TSPlot")|>withSpinner(color="black"))
                                   )
                          ),
                          tabPanel("Last 24-hr Plots",
                                   fluidRow(column(4,offset=0.5),strong(p("Time-series plot of last 24-hr of pollutant parameter",
                                                                          align="center",style = "font-size:18pt"))),
                                   fluidRow(column(4,
                                                   selectInput("site24", "Station", getDelhiSites(df24), width="400pt"),
                                                   selectInput("param24", "Pollutant", c("AQI","PM2.5", "PM10", "NH3", "SO2"), width="400pt"),
                                                   checkboxInput("check24", "Fill the area under the curve", value = FALSE),
                                                   actionButton("plotbutton24", "PLOT",class = "btn-sm btn-primary", width="400pt"),
                                                   br(),br(),br(),br(),br(),br(),br(),
                                                   div(style = "margin: auto; font-size:12pt; text-align:left",
                                                       strong(p("National Ambient Air Quality Standard (\\(\\mu g/m^{3}\\))"))),
                                                   tableOutput("naaqstable24")
                                   ),
                                   column(8, plotlyOutput("TSPlot24")|>withSpinner(color="black"))
                                   )
                          )
               ),
               position = "static-top", windowTitle = "Air Pollution Dashboard")
)
# -------------UI Ends----------------------------------------------------------

# -------------Server Starts----------------------------------------------------

server = function(input, output){
    # -------------HomePage Server------------------------------------------------
    output$stations_ncr = renderImage({
        list(src = "www/stations_ncr.jpg",
             height = 240)}, deleteFile = F)
    
    output$grid_ncr = renderImage({
        list(src = "www/grid_ncr.jpg",
             height = 240)}, deleteFile = F)
    
    output$plot_ncr = renderImage({
        list(src = "www/plot_ncr.jpg",
             height = 240)}, deleteFile = F)
    
    output$plot_delhi = renderImage({
        list(src = "www/plot_delhi.jpg",
             height = 240)}, deleteFile = F)
    # -------------NAAQS Table----------------------------------------------------
    output$naaqstable <- renderTable({
        naaqstab
    },bordered = TRUE, striped=TRUE, width="400pt")
    
    output$naaqstable24 <- renderTable({
        naaqstab24
    },bordered = TRUE, striped=TRUE, width="400pt")
    
    # -------------ChoroplethMap Server-------------------------------------------
    month_update = reactive(getMonths(input$yearMap))
    
    observeEvent(month_update(), {
        choices = month_update()
        updateSelectInput(inputId = "monthMap", choices = choices)
    })
    #First Render
    output$monthlyAvgGlobal = renderImage({list(src="www/monthlyAvg/AQI/Global/2023January.jpg", height=450)}, deleteFile = FALSE)
    output$monthlyAvgLocal = renderImage({list(src="www/monthlyAvg/AQI/Local/2023January.jpg", height=450)}, deleteFile = FALSE)
    
    observeEvent(input$plotbuttonCM,{
        monthlyFileName = reactive(getFileName(isolate(input$yearMap), isolate(input$monthMap)))
        
        output$monthlyAvgGlobal = renderImage({
            list(src=paste("www/monthlyAvg/",isolate(input$paramMap),"/Global/", monthlyFileName(), sep=""),
                 height = 450)},deleteFile = FALSE)
        
        output$monthlyAvgLocal = renderImage({
            list(src=paste("www/monthlyAvg/",isolate(input$paramMap),"/Local/", monthlyFileName(), sep=""),
                 height = 450)},deleteFile = FALSE)
    })
    
    # -------------TSPlot Server--------------------------------------------------
    #First Render
    output$TSPlot = renderPlotly({
        fig = plot_ly(height= 610, type="scatter", mode="markers")
        layout(fig,showlegend=FALSE, dragmode=FALSE, yaxis=list(showgrid=FALSE, zeroline=FALSE, showticklabels=FALSE),
               xaxis=list(showgrid=FALSE, zeroline=FALSE,showticklabels=FALSE), annotations =
                   list(x = 0, y = 1, text="Press the PLOT button! \n Fill will trigger without pressing PLOT", showarrow=FALSE, font=list(size=24, family="Bell MT")))|>
            config(responsive = FALSE,displaylogo = FALSE,
                   modeBarButtonsToRemove = c('zoom','pan','select', 'zoomIn', 'zoomOut', 'lasso2d', 'autoScale', 'resetScale'))
    })
    
    
    observeEvent(input$plotbuttonTS,{
        rangeDataTS = reactive({getRangeDataTS(df, isolate(input$paramTS), isolate(input$daterangeTS[1]),
                                               isolate(input$daterangeTS[2]), isolate(input$siteTS))})
        emptyCol = c()
        for (i in c("darkredp", "redp", "orangep", "yellowp", "greenp", "darkgreenp")){
            if(length(rangeDataTS()[[i]]$x)!=0){
                emptyCol = append(emptyCol, i)
            }
        }
        output$TSPlot = renderPlotly({
            # -------------TSPlot-----------------------------------------------------
            if (input$checkTS==T){
                fig = plot_ly(height= 610)
                for (j in emptyCol){
                    for (i in 1:length(rangeDataTS()[[j]]$x)){
                        fig = add_segments(fig,x = rangeDataTS()[[j]]$x[i], y = rangeDataTS()[[j]]$y[i],
                                           xend = rangeDataTS()[[j]]$xend[i], yend = rangeDataTS()[[j]]$yend[i],
                                           line = list(color = col[[j]]),fill="tozeroy", name = hoverName(input$paramTS,j),
                                           fillcolor=fillcol[[j]])
                    }
                }
                layout(fig,showlegend=FALSE, dragmode=FALSE, yaxis = list(rangemode = "tozero"))|>
                    config(responsive = FALSE,displaylogo = FALSE,
                           modeBarButtonsToRemove = c('zoom','pan','select', 'zoomIn', 'zoomOut', 'lasso2d', 'autoScale', 'resetScale'))
            }
            else{
                fig = plot_ly(height= 610)
                for (j in emptyCol){
                    fig = add_segments(fig, x = rangeDataTS()[[j]]$x, y = rangeDataTS()[[j]]$y,name = hoverName(input$paramTS,j),
                                       xend = rangeDataTS()[[j]]$xend, yend = rangeDataTS()[[j]]$yend, line = list(color = col[[j]]))
                }
                layout(fig,showlegend=FALSE, dragmode=FALSE, yaxis = list(rangemode = "tozero"))|>
                    config(responsive = FALSE,displaylogo = FALSE,
                           modeBarButtonsToRemove = c('zoom','pan','select', 'zoomIn', 'zoomOut', 'lasso2d', 'autoScale', 'resetScale'))
            }
        })
    })
    
    # -------------TSPlot24 Server--------------------------------------------------
    #First Render
    output$TSPlot24 = renderPlotly({
        fig = plot_ly(height= 610)
        layout(fig,showlegend=FALSE, dragmode=FALSE, yaxis=list(showgrid=FALSE, zeroline=FALSE, showticklabels=FALSE),
               xaxis=list(showgrid=FALSE, zeroline=FALSE,showticklabels=FALSE), annotations =
                   list(x = 0, y = 1, text="Press the PLOT button! \n Fill will trigger without pressing PLOT", showarrow=FALSE, font=list(size=24, family="Bell MT")))|>
        config(responsive = FALSE,displaylogo = FALSE,
                   modeBarButtonsToRemove = c('zoom','pan','select', 'zoomIn', 'zoomOut', 'lasso2d', 'autoScale', 'resetScale'))
    })
    
    
    observeEvent(input$plotbutton24,{
        rangeDataTS24 = reactive({getRangeDataTS24(df24, isolate(input$param24), isolate(input$site24))})
        rangeDataTS24Pt = reactive({getRangeDataTS24(df24, isolate(input$param24), isolate(input$site24))})
        if (typeof(rangeDataTS24())=="list"){
            emptyCol = c()
            for (i in c("darkredp", "redp", "orangep", "yellowp", "greenp", "darkgreenp")){
                if(length(rangeDataTS24()[[i]]$x)!=0){
                    emptyCol = append(emptyCol, i)
                }
            }
            output$TSPlot24 = renderPlotly({
                # -------------TSPlot24---------------------------------------------------
                if (input$check24==T){
                    fig = plot_ly(height= 610, type="scatter", mode = "markers", x = rangeDataTS24Pt()$Date, y = rangeDataTS24Pt()$par)
                    for (j in emptyCol){
                        for (i in 1:length(rangeDataTS24()[[j]]$x)){
                            fig = add_segments(fig,x = rangeDataTS24()[[j]]$x[i], y = rangeDataTS24()[[j]]$y[i],
                                               xend = rangeDataTS24()[[j]]$xend[i], yend = rangeDataTS24()[[j]]$yend[i],
                                               line = list(color = col[[j]]),fill="tozeroy", name = hoverName(input$param24,j),
                                               fillcolor=fillcol[[j]], marker = list(size=5, color=  col[[j]]))
                        }
                    }
                    layout(fig,showlegend=FALSE, dragmode=FALSE, yaxis = list(rangemode = "tozero"))|>
                        config(responsive = FALSE,displaylogo = FALSE,
                               modeBarButtonsToRemove = c('zoom','pan','select', 'zoomIn', 'zoomOut', 'lasso2d', 'autoScale', 'resetScale'))
                }
                else{
                    fig = plot_ly(height= 610, type="scatter", mode = "markers", x = rangeDataTS24Pt()$Date, y = rangeDataTS24Pt()$par)
                    for (j in emptyCol){
                        fig = add_segments(fig, x = rangeDataTS24()[[j]]$x, y = rangeDataTS24()[[j]]$y, name = hoverName(input$param24,j),
                                           xend = rangeDataTS24()[[j]]$xend, yend = rangeDataTS24()[[j]]$yend, line = list(color = col[[j]]),
                                           marker = list(size=5, color = col[[j]]))
                    }
                    layout(fig,showlegend=FALSE, dragmode=FALSE, yaxis = list(rangemode = "tozero"))|>
                        config(responsive = FALSE,displaylogo = FALSE,
                               modeBarButtonsToRemove = c('zoom','pan','select', 'zoomIn', 'zoomOut', 'lasso2d', 'autoScale', 'resetScale'))
                }
            })
        }
        else{
            output$TSPlot24 = renderPlotly({
                fig = plot_ly(height= 610)
                layout(fig,showlegend=FALSE, dragmode=FALSE, yaxis=list(showgrid=FALSE, zeroline=FALSE, showticklabels=FALSE),
                       xaxis=list(showgrid=FALSE, zeroline=FALSE,showticklabels=FALSE), annotations =
                           list(x = 0, y = 1, text="No data available", showarrow=FALSE, font=list(size=24, family="Bell MT")))|>
                config(responsive = FALSE,displaylogo = FALSE,
                           modeBarButtonsToRemove = c('zoom','pan','select', 'zoomIn', 'zoomOut', 'lasso2d', 'autoScale', 'resetScale'))
            })
        }
    })
    # -------------Server Ends------------------------------------------------------
}

shinyApp(ui = ui, server = server)
