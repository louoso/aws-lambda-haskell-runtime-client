{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE TypeApplications  #-}

module Main where

import AWS.Lambda.KinesisDataStreamsEvent
import AWS.Lambda.RuntimeClient
import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.Logger
import Control.Monad.Trans.Class
import Data.Text (Text, pack)

main :: IO ()
main = runStderrLoggingT $ do
  client <- runtimeClient
  forever $ echo client

echo :: (MonadLogger m, MonadIO m) => RuntimeClient (KinesisDataStreamsEvent Text) (KinesisDataStreamsEvent Text) m -> m ()
echo RuntimeClient{..} = do
  Event{..} <- getNextEvent
  case eventBody of
    Right (e@KinesisDataStreamsEvent{..}) -> postResponse eventID e
    Left e -> postError eventID $ Error "Unexpected Error" $ pack e
