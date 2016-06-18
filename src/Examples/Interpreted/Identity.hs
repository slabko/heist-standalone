{-# LANGUAGE OverloadedStrings  #-}

module Examples.Interpreted.Identity where

import           Blaze.ByteString.Builder (toByteString)
import           Control.Lens
import           Control.Monad.Identity 
import           Control.Monad.Trans.Either (runEitherT)
import           Data.Map.Syntax
import           Data.Maybe 
import           Heist 
import           System.IO (hFlush, stdout)
import qualified Data.ByteString as B
import qualified Heist.Interpreted as I
import qualified Text.XmlHtml as X

--------------------------------------------------------------------------------
main :: IO ()
main = do
  Right heistState <- runEitherT $ initHeist config
  B.writeFile "index.html" $ runIdentity $ mainIdentity heistState

mainIdentity :: HeistState Identity -> Identity B.ByteString
mainIdentity heistState = do 
  builder <- fst . fromJust <$> I.renderTemplate heistState "simple"
  return $ toByteString builder

--------------------------------------------------------------------------------
config :: Monad m => HeistConfig m 
config = emptyHeistConfig & hcTemplateLocations .~ [loadTemplates "templates"]
                          & hcLoadTimeSplices   .~ splices
                          & hcNamespace         .~ ""

splices :: Monad m => Splices (I.Splice m) 
splices = do
  "link" ## linkSplice 
  "home" ## homeSplice

--------------------------------------------------------------------------------
homeSplice :: Monad m => I.Splice m
homeSplice = I.textSplice "Home, sweet home"

linkSplice :: Monad m => I.Splice m 
linkSplice = return [X.Element "a" 
                      [("href", "http://www.google.com")] 
                      [X.TextNode "Google"]]

