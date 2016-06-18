{-# LANGUAGE OverloadedStrings  #-}

module Examples.Compiled.Render where

import           Blaze.ByteString.Builder (Builder, toByteStringIO)
import           Control.Lens
import           Control.Monad.IO.Class 
import           Control.Monad.Trans.Either (runEitherT)
import           Data.Maybe 
import           Data.Text 
import           Heist 
import qualified Data.ByteString as B
import qualified Heist.Compiled as C
import qualified Text.XmlHtml as X

data Person = Person { pname :: Text }

--------------------------------------------------------------------------------
main :: IO ()
main = do
  Right heistState <- runEitherT $ initHeist config
  builder <- fst $ fromJust $ C.renderTemplate heistState "page"
  toByteStringIO (B.writeFile "index.html") builder

--------------------------------------------------------------------------------
fooSplice :: Monad m => C.Splice m 
fooSplice = C.runChildren

homeSplice :: Monad m => C.Splice m
homeSplice = return $ C.yieldPureText "Home, sweet home"

namesRuntimeSplice :: MonadIO m => [Text] -> RuntimeSplice m Builder
namesRuntimeSplice = undefined

linkRuntimeSplice :: MonadIO m => RuntimeSplice m Builder
linkRuntimeSplice = return $ X.renderHtmlFragment X.UTF8 link
  where
    link = [X.Element "a" 
             [("href", "http://www.google.com")] 
             [X.TextNode $ pack "Google"]]
                      
--------------------------------------------------------------------------------
personSplices :: MonadIO m => Splices (RuntimeSplice m Text -> C.Splice m)
personSplices = "name" ## return . C.yieldRuntimeText

peopleSplice :: MonadIO m => RuntimeSplice m [Text] -> C.Splice m
peopleSplice = C.manyWithSplices C.runChildren personSplices

allPeopleSplice :: MonadIO m => C.Splice m
allPeopleSplice = peopleSplice (return ["Einstein", "Feynman", 
                                        "Heisenberg", "Newton"])

--------------------------------------------------------------------------------
config :: MonadIO m => HeistConfig m 
config = emptyHeistConfig & hcTemplateLocations .~ [loadTemplates "templates"] 
                          & hcCompiledSplices   .~ splices
                          & hcLoadTimeSplices   .~ defaultLoadTimeSplices
                          & hcNamespace         .~ ""

splices :: MonadIO m => Splices (C.Splice m)
splices = do
  "foo"   ## fooSplice 
  "home"  ## homeSplice
  "link"  ## return $ C.yieldRuntime linkRuntimeSplice
  "names" ## allPeopleSplice

