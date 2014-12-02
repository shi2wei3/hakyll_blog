-------------------------------------------------------------------------------
{-# LANGUAGE Arrows             #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE OverloadedStrings  #-}
module Main (main) where

--------------------------------------------------------------------------------
import           Data.Monoid         ((<>), mconcat, mappend)
import           Prelude             hiding (id)
import qualified Text.Pandoc         as Pandoc
--------------------------------------------------------------------------------
import           Hakyll
--------------------------------------------------------------------------------
-- | Entry point
main :: IO ()
main = hakyllWith config $ do
    -- Static files
    match ("favicon.ico" .||. "robots.txt") $ do
        route   idRoute
        compile copyFileCompiler

    -- Compress CSS
    match "css/*" $ do
        route idRoute
        compile compressCssCompiler

    -- Copy JS
    match "js/*" $ do
        route idRoute
        compile copyFileCompiler

    -- copy static assets
    let assets = ["404.html", "github-btn.html", "images/*", "reveal.js/**"]
    match (foldr1 (.||.) assets) $ do
        route   idRoute
        compile copyFileCompiler

    -- Copy Fonts
    match "fonts/*" $ do
        route idRoute
        compile copyFileCompiler

    -- Build tags
    tags <- buildTags "posts/*" (fromCapture "tags/*.html")

    -- Render each and every post
    match "posts/*" $ do
        route   $ setExtension ".html"
        compile $ do
            pandocCompiler
                >>= saveSnapshot "content"
                >>= loadAndApplyTemplate "templates/post.html" (postCtx tags)
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls

    -- Render each and every slide
    match "slides/*" $ do
        route   $ setExtension ".html"
        compile $ do
            pandocRevealJsCompiler
                >>= saveSnapshot "content"
                >>= loadAndApplyTemplate "templates/slides.html" defaultContext
                >>= relativizeUrls

    -- Render each and every news
    match "news/*" $ do
        route   $ setExtension ".html"
        compile $ do
            pandocCompiler
                >>= saveSnapshot "content"
                >>= relativizeUrls

    -- Post list
    create ["posts.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let ctx = constField "title" "Posts" <>
                        listField "posts" (postCtx tags) (return posts) <>
                        defaultContext
            makeItem ""
                >>= loadAndApplyTemplate "templates/posts.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    -- Slide list
    create ["slides.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "slides/*"
            let ctx = constField "title" "Slides" <>
                        listField "posts" (postCtx tags) (return posts) <>
                        defaultContext
            makeItem ""
                >>= loadAndApplyTemplate "templates/posts.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    -- News list
    match "news.html" $ do
        route idRoute
        compile $ do
            news <- recentFirst =<< loadAll "news/*"
            let ctx = constField "title" "News" <>
                        listField "news" (postCtx tags) (return news) <>
                        defaultContext
            getResourceBody
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/main.html" ctx
                >>= relativizeUrls

    -- Post tags
    tagsRules tags $ \tag pattern -> do
        let title = "Posts tagged " ++ tag

        -- Copied from posts, need to refactor
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll pattern
            let ctx = constField "title" title <>
                        listField "posts" (postCtx tags) (return posts) <>
                        defaultContext
            makeItem ""
                >>= loadAndApplyTemplate "templates/posts.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    create ["tags.html"] $ do
        route idRoute
        compile $ do
            let ctx = constField "title" "Tags" `mappend` defaultContext
            renderTagCloud 100 300 tags
                >>= makeItem
                >>= loadAndApplyTemplate "templates/tags.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    -- Index
    match "index.html" $ do
        route idRoute
        compile $ do
            news <- fmap (take 3) . recentFirst =<< loadAll "news/*"
            let ctx =
                    listField "news" (postCtx tags) (return news) <>
                    constField "title" "Index" `mappend` defaultContext
            getResourceBody
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/main.html" ctx
                >>= relativizeUrls

    -- Blog
    match "blog.html" $ do
        route idRoute
        compile $ do
            posts <- fmap (take 18) . recentFirst =<< loadAll "posts/*"
            let indexContext =
                    constField "title" "Blog" <>
                    listField "posts" (postCtx tags) (return posts) <>
                    field "tags" (\_ -> renderTagCloud 100 300 tags) <>
                    defaultContext
            getResourceBody
                >>= applyAsTemplate indexContext
                >>= loadAndApplyTemplate "templates/default.html" indexContext
                >>= relativizeUrls

    -- Read templates
    match "templates/*" $ compile $ templateCompiler

    -- Render some static pages
    match (fromList ["about.markdown"]) $ do
        route   $ setExtension ".html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/contacts.html" defaultContext
            >>= loadAndApplyTemplate "templates/main.html" defaultContext
            >>= relativizeUrls

    match (fromList ["projects.markdown", "research.markdown"]) $ do
        route   $ setExtension ".html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/main.html" defaultContext
            >>= relativizeUrls

    -- Render RSS feed
    create ["rss.xml"] $ do
        let title = "Atom feed"
        route idRoute
        compile $ do
            loadAllSnapshots "posts/*" "content"
                >>= fmap (take 10) . recentFirst
                >>= renderAtom (feedConfiguration title) feedCtx

--------------------------------------------------------------------------------
pandocRevealJsCompiler :: Compiler (Item String)
pandocRevealJsCompiler =
    let writerOptions = Pandoc.def {
                          Pandoc.writerHtml5  = True,
                          Pandoc.writerSlideVariant=Pandoc.RevealJsSlides
                        }
    in pandocCompilerWith defaultHakyllReaderOptions writerOptions
--------------------------------------------------------------------------------
postCtx :: Tags -> Context String
postCtx tags = mconcat
    [ modificationTimeField "mtime" "%U"
    , dateField "date" "%B %e, %Y"
    , tagsField "tags" tags
    , defaultContext
    ]
--------------------------------------------------------------------------------
feedCtx :: Context String
feedCtx = mconcat
    [ bodyField "description"
    , defaultContext
    ]
--------------------------------------------------------------------------------
config :: Configuration
config = defaultConfiguration
    { deployCommand = "rsync --checksum --delete -ave 'ssh' \
                       \_site/* shi2wei3@github.com:shi2wei3.github.io"
    }
--------------------------------------------------------------------------------

feedConfiguration :: String -> FeedConfiguration
feedConfiguration title = FeedConfiguration
    { feedTitle       = "John - " ++ title
    , feedDescription = "Personal blog of Wei Shi"
    , feedAuthorName  = "Wei Shi"
    , feedAuthorEmail = "shi2wie3@gmail.com"
    , feedRoot        = "http://shi2wei3.github.io"
    }
--------------------------------------------------------------------------------

