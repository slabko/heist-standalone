{-# LANGUAGE OverloadedStrings  #-}

module Examples.Interpreted.Render where

import           Blaze.ByteString.Builder (toByteStringIO)
import           Control.Lens
import           Control.Monad.IO.Class
import           Control.Monad.Trans.Either (runEitherT)
import           Data.Map.Syntax
import           Data.Maybe 
import           Data.Text 
import           Heist 
import           System.IO (hFlush, stdout)
import qualified Data.ByteString as B
import qualified Heist.Interpreted as I
import qualified Text.XmlHtml as X

--------------------------------------------------------------------------------
main :: IO ()
main = do
  eitherHeistState <- runEitherT $ initHeist config
  case eitherHeistState of
    Left errs -> mapM_ putStrLn errs
    Right heistState -> do
      builder <- fst . fromJust <$> I.renderTemplate heistState "page"
      toByteStringIO (B.writeFile "index.html") builder

--------------------------------------------------------------------------------
config :: MonadIO m => HeistConfig m 
config = emptyHeistConfig & hcTemplateLocations .~ [loadTemplates "templates"]
                          & hcLoadTimeSplices   .~ splices
                          & hcNamespace         .~ ""

splices :: MonadIO m => Splices (I.Splice m) 
splices = do
  defaultInterpretedSplices
  "foo"   ## fooSplice 
  "link"  ## linkSplice 
  "home"  ## homeSplice
  "names" ## (nameListSplice ["Einstein", "Feynman", 
                              "Heisenberg", "Newton"])

--------------------------------------------------------------------------------
fooSplice :: Monad m => I.Splice m 
fooSplice = I.runChildren

homeSplice :: Monad m => I.Splice m
homeSplice = I.textSplice "Home, sweet home"

linkSplice :: Monad m => I.Splice m 
linkSplice = return [X.Element "a" 
                      [("href", "http://www.google.com")] 
                      [X.TextNode $ pack "Google"]]

--------------------------------------------------------------------------------
nameSplice :: Monad m => Text -> Splices (I.Splice m)
nameSplice name = "name" ## I.textSplice name

nameListSplice :: Monad m => [Text] -> I.Splice m
nameListSplice = I.mapSplices (I.runChildrenWith . nameSplice)
