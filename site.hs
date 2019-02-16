--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}

import           Data.Monoid        (mappend)
import           Data.Time.Calendar
import           Data.Time.Clock
import           Debug.Trace
import qualified GHC.IO.Encoding    as E
import           Hakyll

--------------------------------------------------------------------------------
main :: IO ()
main = do
  E.setLocaleEncoding E.utf8
  today <- getTodaysDate
  print today
  hakyll $ do
    match "images/*" $ do
      route idRoute
      compile copyFileCompiler
    match "css/*" $ do
      route idRoute
      compile compressCssCompiler
    match "contact.html" $ do
      route idRoute
      compile $
        getResourceBody >>=
        loadAndApplyTemplate "templates/default.html" defaultContext
    match "about.md" $ do
      route $ setExtension "html"
      compile $
        pandocCompiler >>=
        loadAndApplyTemplate "templates/measure.html" defaultContext >>=
        loadAndApplyTemplate "templates/default.html" defaultContext >>=
        relativizeUrls
    match "posts/*" $ do
      route $ setExtension "html"
      compile $ do
        filepath <- getResourceFilePath
        posts <- recentFirst =<< loadAll (getBookFolder filepath)
        let bookCtx = listField "posts" postCtx (return posts) <> defaultContext
        getResourceBody >>= applyAsTemplate bookCtx >>=
          loadAndApplyTemplate "templates/book.html" bookCtx >>=
          loadAndApplyTemplate "templates/default.html" bookCtx >>=
          relativizeUrls
    match "posts/*/*" $ do
      route $ setExtension "html"
      compile $
        pandocCompiler >>= loadAndApplyTemplate "templates/post.html" postCtx >>=
        loadAndApplyTemplate "templates/default.html" postCtx >>=
        relativizeUrls
    create ["archive.html"] $ do
      route idRoute
      compile $ do
        posts <- recentFirst =<< loadAll "posts/*/*"
        books <- recentFirst =<< loadAll "posts/*"
        let archiveCtx =
              listField "posts" defaultContext (return posts) <>
              listField "books" defaultContext (return books) <>
              constField "title" "Archives" <>
              defaultContext
        makeItem "" >>= loadAndApplyTemplate "templates/archive.html" archiveCtx >>=
          loadAndApplyTemplate "templates/measure.html" archiveCtx >>=
          loadAndApplyTemplate "templates/default.html" archiveCtx >>=
          relativizeUrls
    create ["sitemap.xml"] $ do
      route idRoute
      compile $ do
        posts <- recentFirst =<< loadAll "posts/*/*"
        books <- recentFirst =<< loadAll "posts/*"
        let allPosts = return (posts ++ books)
        let sitemapCtx =
              listField "entries" defaultContext allPosts <>
              constField "today" today <>
              defaultContext
        makeItem "" >>= loadAndApplyTemplate "templates/sitemap.xml" sitemapCtx
    match "index.html" $ do
      route idRoute
      compile $ do
        posts <- recentFirst =<< loadAll "posts/*/*"
        books <- recentFirst =<< loadAll "posts/*"
        let indexCtx =
              listField "posts" defaultContext (return $ take 5 posts) <>
              listField "books" defaultContext (return $ take 5 books) <>
              constField "title" "Home" <>
              defaultContext
        getResourceBody >>= applyAsTemplate indexCtx >>=
          loadAndApplyTemplate "templates/default.html" indexCtx >>=
          relativizeUrls
    match "templates/*" $ compile templateBodyCompiler

--------------------------------------------------------------------------------
postCtx :: Context String
postCtx = defaultContext

getBookFolder :: FilePath -> Pattern
getBookFolder = fromGlob . (++ "/*") . takeWhile (/= '.') . drop 3 . show

getTodaysDate :: IO String
getTodaysDate = do
  (year, month, day) <- getCurrentTime >>= return . toGregorian . utctDay
  return $ show year ++ "-" ++ show month ++ "-" ++ show day
